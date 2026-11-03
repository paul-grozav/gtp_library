#!/usr/bin/env python3
import curses
import shutil
import subprocess
import sys

# Automatically detect container engine
if shutil.which("podman"):
  CONTAINER_CMD = "podman"
elif shutil.which("docker"):
  CONTAINER_CMD = "docker"
else:
  print(
    "Error: Neither podman nor docker was found in your PATH.",
    file=sys.stderr,
  )
  sys.exit(1)


def get_images():
  """Fetch images from the container runtime."""
  try:
    cmd = [
      CONTAINER_CMD,
      "images",
      "--format",
      "{{.Repository}}:{{.Tag}} | {{.ID}} | {{.Size}}",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)

    images = []
    for line in result.stdout.strip().split("\n"):
      if line:
        parts = line.split(" | ")
        repo_tag = parts[0]
        img_id = parts[1] if len(parts) > 1 else repo_tag
        size = parts[2] if len(parts) > 2 else ""
        display_text = f"{repo_tag:<45} | {img_id[:12]:<15} | {size}"
        # Format: [Selected (bool), Display String, Image ID]
        images.append([False, display_text, img_id])
    return images
  except subprocess.CalledProcessError as e:
    print(f"Error fetching images: {e.stderr}", file=sys.stderr)
    sys.exit(1)


def draw_menu(stdscr):
  # Curses settings
  curses.curs_set(0)
  curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)  # Highlighted row
  curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)  # Selected checkbox
  curses.init_pair(3, curses.COLOR_CYAN, curses.COLOR_BLACK)  # Scrollbar track

  images = get_images()
  current_row = 0
  scroll_top = 0  # Index of the top visible item

  while True:
    stdscr.clear()
    h, w = stdscr.getmaxyx()

    # Reserve spaces for Headers (4 lines) and Footer (1 line)
    max_visible_items = h - 6

    # Adjust scrolling window position
    if current_row < scroll_top:
      scroll_top = current_row
    elif current_row >= scroll_top + max_visible_items:
      scroll_top = current_row - max_visible_items + 1

    # Render Header Info
    stdscr.addstr(
      0,
      0,
      f"--- {CONTAINER_CMD.upper()} Image Manager (ncurses) ---",
      curses.A_BOLD,
    )
    stdscr.addstr(
      1,
      0,
      "Controls: [Arrows] Navigate | [Space] Select | [Enter] Delete | [Q] Quit",
    )
    stdscr.addstr(
      3,
      0,
      f"   {'Repository:Tag':<45} | {'Image ID':<15} | Size",
      curses.A_UNDERLINE,
    )

    if not images:
      stdscr.addstr(5, 4, "No local container images found.")

    # Determine bounds of rendered section
    visible_subset = images[scroll_top : scroll_top + max_visible_items]

    for idx, item in enumerate(visible_subset):
      absolute_idx = scroll_top + idx
      checked, text, _ = item
      bracket = "[X]" if checked else "[ ]"

      # Print list element row
      if absolute_idx == current_row:
        stdscr.attron(curses.color_pair(1))
        stdscr.addstr(4 + idx, 0, f"{bracket} {text:<{w-7}}")
        stdscr.attroff(curses.color_pair(1))
      else:
        if checked:
          stdscr.attron(curses.color_pair(2))
          stdscr.addstr(4 + idx, 0, f"{bracket} {text}")
          stdscr.attroff(curses.color_pair(2))
        else:
          stdscr.addstr(4 + idx, 0, f"{bracket} {text}")

    # --- DRAW VISUAL SCROLL BAR ---
    total_items = len(images)
    if total_items > max_visible_items:
      scrollbar_x = min(w - 2, 79)  # Align right bound safely

      # Draw background vertical track
      for i in range(min(max_visible_items, total_items)):
        stdscr.addstr(4 + i, scrollbar_x, "│", curses.color_pair(3))

      # Calculate scale matching total contents size
      bar_height = max(
        1, int((max_visible_items / total_items) * max_visible_items)
      )
      bar_start = int((scroll_top / total_items) * max_visible_items)

      # Cap limits cleanly
      if bar_start + bar_height > max_visible_items:
        bar_start = max_visible_items - bar_height

      # Draw active slider chunk overlay
      for i in range(bar_height):
        stdscr.addstr(
          4 + bar_start + i,
          scrollbar_x,
          "█",
          curses.color_pair(3) | curses.A_BOLD,
        )

    stdscr.refresh()
    key = stdscr.getch()

    # Key Navigation Logic
    if key == curses.KEY_UP and current_row > 0:
      current_row -= 1
    elif key == curses.KEY_DOWN and current_row < len(images) - 1:
      current_row += 1
    elif key == ord(" "):
      if images:
        images[current_row][0] = not images[current_row][0]
    elif key in [ord("\n"), curses.KEY_ENTER]:
      selected_items = [img for img in images if img[0]]

      if not selected_items:
        continue

      # Confirm Deletion Menu
      stdscr.clear()
      stdscr.addstr(
        0,
        0,
        f"Are you sure you want to remove {len(selected_items)} selected images? (y/n)",
        curses.A_BOLD,
      )
      stdscr.refresh()

      conf_key = stdscr.getch()
      if conf_key in [ord("y"), ord("Y")]:
        success, errors = [], []
        total_to_remove = len(selected_items)

        # Process Deletions with Status Updates
        for current_count, item in enumerate(selected_items, 1):
          _, _, img_id = item
          short_id = img_id[:12]

          stdscr.clear()
          stdscr.addstr(0, 0, "Removing Images...", curses.A_BOLD)
          stdscr.addstr(
            2,
            0,
            f"Progress: [{current_count}/{total_to_remove}] processing ID {short_id}...",
          )
          stdscr.refresh()

          # Trigger system removal command
          cmd = [CONTAINER_CMD, "rmi", img_id]
          res = subprocess.run(cmd, capture_output=True, text=True)

          if res.returncode == 0:
            success.append(short_id)
          else:
            errors.append(f"{short_id}: {res.stderr.strip()}")

        # Output complete operation summary
        stdscr.clear()
        stdscr.addstr(0, 0, "--- REMOVAL SUMMARY ---", curses.A_BOLD)
        row_offset = 2

        if success:
          stdscr.addstr(
            row_offset, 0, f"Successfully removed: {', '.join(success)}"
          )
          row_offset += 2
        if errors:
          stdscr.addstr(row_offset, 0, "Errors encountered:")
          row_offset += 1
          for err in errors:
            if row_offset < h - 2:
              stdscr.addstr(row_offset, 2, f"- {err}")
              row_offset += 1

        stdscr.addstr(
          row_offset + 1, 0, "Press any key to reload image inventory..."
        )
        stdscr.refresh()
        stdscr.getch()

        # Reset indexes and fetch pristine stack
        images = get_images()
        current_row = 0
        scroll_top = 0

    elif key in [ord("q"), ord("Q")]:
      break


if __name__ == "__main__":
  curses.wrapper(draw_menu)