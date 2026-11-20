// -------------------------------------------------------------------------- //
// Author: Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
// Compile and run:
// g++ -o hello_gui hello_gui.cpp -lX11 && ./hello_gui
// -------------------------------------------------------------------------- //
#include <X11/Xlib.h>
#include <cstring>

int main() {
  Display* display = XOpenDisplay(nullptr);
  if (!display) {
    return 1;
  }
  int screen = DefaultScreen(display);
  const int width = 480;
  const int height = 180;
  Window window = XCreateSimpleWindow(
    display,
    RootWindow(display, screen),
    160, 140, width, height, 1,
    BlackPixel(display, screen),
    WhitePixel(display, screen));
  XStoreName(display, window, "Hello");
  Atom wmDelete = XInternAtom(display, "WM_DELETE_WINDOW", False);
  XSetWMProtocols(display, window, &wmDelete, 1);
  XSelectInput(display, window, ExposureMask | KeyPressMask);
  XMapWindow(display, window);
  GC gc = XCreateGC(display, window, 0, nullptr);
  XSetForeground(display, gc, BlackPixel(display, screen));
  XFontStruct* font = XLoadQueryFont(display,
    "-*-helvetica-bold-r-*-*-24-*-*-*-*-*-*-*");
  if (!font) {
    font = XLoadQueryFont(display, "fixed");
  }
  if (font) {
    XSetFont(display, gc, font->fid);
  }
  const char* message = "Hello, world!";
  for (;;) {
    XEvent event;
    XNextEvent(display, &event);
    if (event.type == Expose) {
      int textWidth = font ? XTextWidth(font, message,
        static_cast<int>(std::strlen(message))) : 100;
      int x = (width - textWidth) / 2;
      XClearWindow(display, window);
      XDrawString(display, window, gc, x, 100, message,
        static_cast<int>(std::strlen(message)));
    } else if (event.type == ClientMessage &&
        static_cast<unsigned long>(event.xclient.data.l[0]) == wmDelete) {
      break;
    } else if (event.type == KeyPress) {
      break;
    }
  }
  XCloseDisplay(display);
  return 0;
}
// -------------------------------------------------------------------------- //
