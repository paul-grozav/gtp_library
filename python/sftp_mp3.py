#!/usr/bin/env python3
"""Browse an sftp:// folder for .mp3 files with an ncurses UI; play via mpv --ao=pulse.

Host, user, port, and keys come from ~/.ssh/config (key-based auth).

Usage:
  ./sftp_mp3.py sftp://serverHostname/path/to/folder/

Keys:
  ↑/↓  j/k     move
  Enter / p    play focused track (modal + mpv output)
  Space        toggle mark
  a            play marked (or all if none marked)
  Esc          stop player (while modal open)
  r            refresh list
  q            quit
"""

from __future__ import annotations

import argparse
import curses
import errno
import fcntl
import os
import pty
import re
import select
import shlex
import shutil
import signal
import struct
import subprocess
import sys
import termios
from urllib.parse import unquote, urlparse


MPV_AO = ["--ao=pulse"]
# Force a clear CR-updated status line (time progress) on the PTY.
MPV_TERM = [
    "--terminal=yes",
    "--term-osd=force",
    "--term-status-msg=A: ${time-pos} / ${duration} (${percent-pos}%)",
]
_ANSI_RE = re.compile(
    r"\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|].*?(?:\x07|\x1b\\))"
)


def _set_pty_winsize(fd: int, rows: int, cols: int) -> None:
    packed = struct.pack("HHHH", max(1, rows), max(1, cols), 0, 0)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, packed)


def parse_sftp_url(url: str) -> tuple[str, str, str]:
    """Return (host, remote_path, base_url).

    URL must be sftp://HOST/path — no user, password, or port.
    HOST is an ~/.ssh/config Host alias (key auth).
    """
    parsed = urlparse(url)
    if parsed.scheme != "sftp":
        raise SystemExit(f"Expected sftp:// URL, got: {url}")
    if not parsed.hostname:
        raise SystemExit(f"Missing host in URL: {url}")
    if parsed.username or parsed.password is not None or parsed.port is not None:
        raise SystemExit(
            "URL must be sftp://HOST/path (no user, password, or port). "
            "Put those in ~/.ssh/config for HOST."
        )

    host = parsed.hostname
    path = unquote(parsed.path or "/")
    if not path.endswith("/"):
        if path.lower().endswith(".mp3"):
            path = path.rsplit("/", 1)[0] + "/"
        else:
            path += "/"

    base_url = f"sftp://{host}{path}"
    return host, path, base_url


def list_remote_mp3s(host: str, remote_path: str) -> list[str]:
    """List .mp3 files via OpenSSH (honours ~/.ssh/config)."""
    remote_cmd = (
        f"find {shlex.quote(remote_path)} -type f "
        f"-iname '*.mp3' -printf '%P\\n' | sort"
    )
    ssh_cmd = [
        "ssh",
        "-o",
        "BatchMode=yes",
        "-o",
        "ConnectTimeout=15",
        host,
        remote_cmd,
    ]
    result = subprocess.run(
        ssh_cmd,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        err = (result.stderr or result.stdout or "").strip()
        raise SystemExit(
            f"ssh failed ({result.returncode}) for host {host!r} "
            f"(check ~/.ssh/config / keys): {err}"
        )

    return [line for line in result.stdout.splitlines() if line.strip()]


def _clip(text: str, width: int) -> str:
    if width <= 0:
        return ""
    if len(text) <= width:
        return text
    if width <= 1:
        return text[:width]
    return text[: width - 1] + "…"


def _strip_ansi(text: str) -> str:
    return _ANSI_RE.sub("", text)


def _kill_proc(proc: subprocess.Popen) -> None:
    if proc.poll() is not None:
        return
    try:
        os.killpg(proc.pid, signal.SIGTERM)
    except (ProcessLookupError, PermissionError):
        try:
            proc.terminate()
        except ProcessLookupError:
            return
    try:
        proc.wait(timeout=2)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except (ProcessLookupError, PermissionError):
            try:
                proc.kill()
            except ProcessLookupError:
                pass
        try:
            proc.wait(timeout=1)
        except subprocess.TimeoutExpired:
            pass


class PlayerUI:
    def __init__(
        self,
        stdscr: curses.window,
        files: list[str],
        host: str,
        remote_path: str,
        title: str,
        reload_fn,
    ) -> None:
        self.stdscr = stdscr
        self.files = files
        self.host = host
        self.remote_path = remote_path
        self.title = title
        self.reload_fn = reload_fn
        self.cursor = 0
        self.offset = 0
        self.marked: set[int] = set()
        self.status = f"{len(files)} track(s)"
        self.last_cmd = ""

    def _layout(self) -> tuple[int, int, int]:
        h, w = self.stdscr.getmaxyx()
        header = 2
        footer = 2
        body = max(1, h - header - footer)
        return h, w, body

    def _ensure_visible(self, body: int) -> None:
        if self.cursor < self.offset:
            self.offset = self.cursor
        elif self.cursor >= self.offset + body:
            self.offset = self.cursor - body + 1

    def draw(self) -> None:
        self.stdscr.erase()
        h, w, body = self._layout()
        self._ensure_visible(body)

        header = _clip(f" sftp_mp3  |  {self.title}", w - 1)
        try:
            self.stdscr.attron(curses.A_REVERSE)
            self.stdscr.addnstr(0, 0, header.ljust(max(0, w - 1)), w - 1)
            self.stdscr.attroff(curses.A_REVERSE)
        except curses.error:
            pass

        help_line = _clip(
            " ↑↓/jk move  Enter/p play  Space mark  a play marked"
            "  Esc stop  r refresh  q quit",
            w - 1,
        )
        try:
            self.stdscr.addnstr(1, 0, help_line, w - 1)
        except curses.error:
            pass

        if not self.files:
            try:
                self.stdscr.addnstr(3, 2, "(no .mp3 files)", w - 3)
            except curses.error:
                pass
        else:
            for row in range(body):
                idx = self.offset + row
                if idx >= len(self.files):
                    break
                mark = "*" if idx in self.marked else " "
                focus = ">" if idx == self.cursor else " "
                line = _clip(f" {focus}{mark} {idx + 1:3d}. {self.files[idx]}", w - 1)
                y = 2 + row
                try:
                    if idx == self.cursor:
                        self.stdscr.attron(curses.A_REVERSE)
                        self.stdscr.addnstr(y, 0, line.ljust(max(0, w - 1)), w - 1)
                        self.stdscr.attroff(curses.A_REVERSE)
                    else:
                        self.stdscr.addnstr(y, 0, line, w - 1)
                except curses.error:
                    pass

        status = self.status
        if self.last_cmd:
            status = f"{status}  |  {self.last_cmd}"
        try:
            self.stdscr.attron(curses.A_REVERSE)
            self.stdscr.addnstr(
                h - 1, 0, _clip(" " + status, w - 1).ljust(max(0, w - 1)), w - 1
            )
            self.stdscr.attroff(curses.A_REVERSE)
        except curses.error:
            pass

        self.stdscr.noutrefresh()

    def _draw_play_modal(
        self,
        name: str,
        cmd: list[str],
        lines: list[str],
        live_line: str,
    ) -> None:
        self.draw()
        h, w = self.stdscr.getmaxyx()
        mh = max(8, min(h - 2, (h * 2) // 3))
        mw = max(30, min(w - 2, (w * 5) // 6))
        my = max(0, (h - mh) // 2)
        mx = max(0, (w - mw) // 2)

        win = curses.newwin(mh, mw, my, mx)
        win.erase()
        win.box()
        inner = max(1, mw - 4)
        try:
            win.addnstr(0, 2, _clip(f" Playing: {name} ", inner), inner, curses.A_BOLD)
            win.addnstr(1, 2, _clip("Esc = stop player", inner), inner)
        except curses.error:
            pass

        body_top = 2
        # Fixed progress row near the bottom of the body; history above it.
        progress_y = mh - 3
        hist_bottom = progress_y - 1
        hist_h = max(0, hist_bottom - body_top + 1)
        hist = lines[-hist_h:] if hist_h > 0 else []
        for i, line in enumerate(hist):
            try:
                win.addnstr(body_top + i, 2, _clip(line, inner), inner)
            except curses.error:
                pass
        progress = live_line or "A: --:--:-- / --:--:-- (--%)"
        try:
            win.addnstr(
                progress_y,
                2,
                _clip(progress, inner).ljust(inner)[:inner],
                inner,
                curses.A_REVERSE,
            )
        except curses.error:
            pass

        try:
            win.addnstr(
                mh - 2,
                2,
                _clip(" ".join(shlex.quote(a) for a in cmd), inner),
                inner,
            )
        except curses.error:
            pass

        win.noutrefresh()
        curses.doupdate()

    def _feed_output(
        self,
        pending: str,
        chunk: str,
        lines: list[str],
        max_lines: int,
        prev_live: str,
    ) -> tuple[str, str]:
        """Parse PTY chunk into log lines + live \\r status. Returns (pending, live)."""
        pending += chunk.replace("\r\n", "\n")
        live = prev_live
        saw_cr = False
        while True:
            nl = pending.find("\n")
            cr = pending.find("\r")
            if nl == -1 and cr == -1:
                break
            if nl != -1 and (cr == -1 or nl < cr):
                raw, pending = pending[:nl], pending[nl + 1 :]
                if "\r" in raw:
                    raw = raw.split("\r")[-1]
                    saw_cr = True
                text = _strip_ansi(raw).rstrip()
                if text:
                    # Prefer time-progress lines as live status.
                    if re.search(r"\d+:\d+", text) or text.startswith("A:"):
                        live = text
                    else:
                        lines.append(text)
                        if len(lines) > max_lines:
                            del lines[:-max_lines]
            else:
                # Carriage return: take text after last \\r as live status.
                parts = pending.split("\r")
                pending = parts[-1]
                text = _strip_ansi(pending).strip()
                if text:
                    live = text
                saw_cr = True
                break
        if not saw_cr and pending and "\n" not in pending and "\r" not in pending:
            text = _strip_ansi(pending).strip()
            if text and (re.search(r"\d+:\d+", text) or text.startswith("A:")):
                live = text
        return pending, live

    def _play_one_modal(self, name: str) -> tuple[list[str], int, bool]:
        """Play one track in a modal with mpv sftp:// URL directly."""
        # Literal spaces in the URL (argv list — not a shell). Same as:
        #   mpv 'sftp://host/path/Sa scapam de Vrajitoare.mp3'
        url = f"sftp://{self.host}{self.remote_path}{name}"
        cmd = ["mpv", *MPV_AO, *MPV_TERM, "--", url]
        self.last_cmd = " ".join(shlex.quote(a) for a in cmd)

        h, w = self.stdscr.getmaxyx()
        mh = max(8, min(h - 2, (h * 2) // 3))
        mw = max(30, min(w - 2, (w * 5) // 6))

        master, slave = pty.openpty()
        try:
            _set_pty_winsize(slave, mh, mw)
            env = os.environ.copy()
            env.setdefault("TERM", "xterm-256color")
            env["COLUMNS"] = str(mw)
            env["LINES"] = str(mh)
            proc = subprocess.Popen(
                cmd,
                stdin=slave,
                stdout=slave,
                stderr=slave,
                close_fds=True,
                start_new_session=True,
                env=env,
            )
        except OSError as exc:
            os.close(master)
            os.close(slave)
            lines = [f"Failed to start mpv: {exc}"]
            self._draw_play_modal(name, cmd, lines, "")
            self.stdscr.timeout(1500)
            self.stdscr.getch()
            self.stdscr.timeout(-1)
            return cmd, 1, False
        os.close(slave)

        lines: list[str] = []
        pending = ""
        live = ""
        stopped = False
        self.stdscr.nodelay(True)

        try:
            while True:
                # Drain PTY output.
                while True:
                    ready, _, _ = select.select([master], [], [], 0)
                    if not ready:
                        break
                    try:
                        data = os.read(master, 4096)
                    except OSError as exc:
                        if exc.errno in (errno.EIO, errno.EAGAIN):
                            data = b""
                        else:
                            raise
                    if not data:
                        break
                    pending, live = self._feed_output(
                        pending,
                        data.decode("utf-8", errors="replace"),
                        lines,
                        500,
                        live,
                    )

                self._draw_play_modal(name, cmd, lines, live)

                ch = self.stdscr.getch()
                if ch == 27:  # Escape
                    stopped = True
                    _kill_proc(proc)
                    lines.append("^ Esc — stopped")
                    self._draw_play_modal(name, cmd, lines, "")
                    break

                if proc.poll() is not None:
                    # Final drain.
                    while True:
                        ready, _, _ = select.select([master], [], [], 0.05)
                        if not ready:
                            break
                        try:
                            data = os.read(master, 4096)
                        except OSError:
                            break
                        if not data:
                            break
                        pending, live = self._feed_output(
                            pending,
                            data.decode("utf-8", errors="replace"),
                            lines,
                            500,
                            live,
                        )
                    if pending.strip():
                        text = _strip_ansi(pending.replace("\r", "")).strip()
                        if text:
                            lines.append(text)
                    self._draw_play_modal(name, cmd, lines, live)
                    break

                # Avoid busy-spinning.
                select.select([master], [], [], 0.05)
        finally:
            try:
                os.close(master)
            except OSError:
                pass
            if proc.poll() is None:
                _kill_proc(proc)
            self.stdscr.nodelay(False)
            self.stdscr.timeout(-1)

        rc = proc.returncode if proc.returncode is not None else 0
        return cmd, rc, stopped

    def _play_names(self, names: list[str]) -> None:
        if not names:
            self.status = "Nothing to play"
            return
        for i, name in enumerate(names, 1):
            self.status = f"Playing [{i}/{len(names)}] {name}"
            cmd, rc, stopped = self._play_one_modal(name)
            self.last_cmd = " ".join(shlex.quote(a) for a in cmd)
            if stopped:
                self.status = f"Stopped: {name}"
                break
            if rc != 0:
                self.status = f"mpv exited {rc}: {name}"
            else:
                self.status = f"Finished: {name}"

    def run(self) -> None:
        curses.curs_set(0)
        self.stdscr.keypad(True)
        self.stdscr.timeout(-1)

        while True:
            self.draw()
            curses.doupdate()
            ch = self.stdscr.getch()
            _, _, body = self._layout()

            if ch in (ord("q"), ord("Q")):
                break
            if ch in (curses.KEY_UP, ord("k")):
                if self.files:
                    self.cursor = max(0, self.cursor - 1)
            elif ch in (curses.KEY_DOWN, ord("j")):
                if self.files:
                    self.cursor = min(len(self.files) - 1, self.cursor + 1)
            elif ch == curses.KEY_PPAGE:
                self.cursor = max(0, self.cursor - body)
            elif ch == curses.KEY_NPAGE:
                if self.files:
                    self.cursor = min(len(self.files) - 1, self.cursor + body)
            elif ch == curses.KEY_HOME:
                self.cursor = 0
            elif ch == curses.KEY_END:
                if self.files:
                    self.cursor = len(self.files) - 1
            elif ch == ord(" "):
                if self.files:
                    if self.cursor in self.marked:
                        self.marked.discard(self.cursor)
                    else:
                        self.marked.add(self.cursor)
                    self.cursor = min(len(self.files) - 1, self.cursor + 1)
            elif ch in (curses.KEY_ENTER, 10, 13, ord("p"), ord("P")):
                if self.files:
                    self._play_names([self.files[self.cursor]])
            elif ch in (ord("a"), ord("A")):
                if self.marked:
                    names = [self.files[i] for i in sorted(self.marked)]
                else:
                    names = list(self.files)
                self._play_names(names)
            elif ch in (ord("r"), ord("R")):
                self.status = "Refreshing…"
                self.draw()
                curses.doupdate()
                try:
                    self.files = self.reload_fn()
                    self.marked.clear()
                    self.cursor = min(self.cursor, max(0, len(self.files) - 1))
                    self.offset = 0
                    self.status = f"Refreshed — {len(self.files)} track(s)"
                except SystemExit as exc:
                    self.status = str(exc)
                except OSError as exc:
                    self.status = f"Refresh failed: {exc}"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Ncurses SFTP .mp3 browser; play with mpv --ao=pulse."
    )
    parser.add_argument(
        "url",
        help="SFTP folder URL: sftp://HOST/path/ (HOST from ~/.ssh/config, key auth)",
    )
    args = parser.parse_args()

    if shutil.which("mpv") is None:
        print("mpv not found in PATH", file=sys.stderr)
        return 1
    if not sys.stdout.isatty():
        print("Need a TTY for the ncurses UI", file=sys.stderr)
        return 1

    host, remote_path, _base_url = parse_sftp_url(args.url)
    title = f"{host}:{remote_path} (ssh config / key)"

    print(f"Listing .mp3 under {title}…", file=sys.stderr)
    files = list_remote_mp3s(host, remote_path)

    def reload_fn() -> list[str]:
        return list_remote_mp3s(host, remote_path)

    def _curses_main(stdscr: curses.window) -> None:
        ui = PlayerUI(stdscr, files, host, remote_path, title, reload_fn)
        ui.run()

    curses.wrapper(_curses_main)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
