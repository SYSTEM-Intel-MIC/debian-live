#!/usr/bin/env python3
"""Patch the Lindows ElevenDE shell to relayout after RandR changes."""
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: patch-elevende-shell-display.py PATH_TO_MAIN_C")
path = Path(sys.argv[1])
text = path.read_text()

old_decl = "static Window mk_owindow(int x, int y, int w, int h);\n"
new_decl = old_decl + "static void set_wm_state(Window w);\nstatic void power_hide(void);\nstatic volatile sig_atomic_t lindows_screen_dirty = 0;\nstatic void lindows_screen_signal(int sig) { (void)sig; lindows_screen_dirty = 1; }\n"
if old_decl not in text:
    raise SystemExit("window declaration marker not found")
text = text.replace(old_decl, new_decl, 1)

old_set = '''static void set_wm_state(Window w) {
'''
new_set = '''static void set_wm_state(Window w) {
'''
# Keep the existing function unchanged; the relayout helper is inserted before it.
marker = "/* ---------------------------------------------------------------- windows */\n"
helper = '''/* Recompute all shell-owned geometry after an XRandR mode change.  The
 * Settings app signals us after xrandr returns; ConfigureNotify is also
 * handled below for display servers that emit it on the root window. */
static void lindows_relayout_screen(void) {
    int nw = XWidthOfScreen(ScreenOfDisplay(dpy, scr));
    int nh = XHeightOfScreen(ScreenOfDisplay(dpy, scr));
    if (nw <= 0 || nh <= 0 || (nw == scr_w && nh == scr_h))
        return;
    scr_w = nw;
    scr_h = nh;
    if (win_bar) {
        XMoveResizeWindow(dpy, win_bar, 0, scr_h - BAR_H, scr_w, BAR_H);
        edge_r = (RRect){ scr_w - 9, 0, 9, BAR_H };
        clock_r = (RRect){ scr_w - 9 - 92, 0, 88, BAR_H };
        im_r = (RRect){ clock_r.x - 4 - 44, (BAR_H - 36) / 2, 44, 36 };
        pill_r = (RRect){ im_r.x - 4 - 82, (BAR_H - 36) / 2, 82, 36 };
        set_wm_state(win_bar);
    }
    if (win_desk) {
        XMoveResizeWindow(dpy, win_desk, 0, 0, scr_w, scr_h - BAR_H);
        XLowerWindow(dpy, win_desk);
    }
    /* Flyouts/search may otherwise retain coordinates outside the new screen. */
    menu_hide();
    search_hide();
    power_hide();
    pinmenu_hide();
    ctx_hide();
    dm_hide();
    icon_layout();
    desk_dirty = 1;
    XClearArea(dpy, win_bar, 0, 0, 0, 0, True);
    XClearArea(dpy, win_desk, 0, 0, 0, 0, True);
    XRaiseWindow(dpy, win_bar);
    XFlush(dpy);
}

'''
if marker not in text:
    raise SystemExit("window section marker not found")
text = text.replace(marker, marker + helper, 1)

old_init = '''    signal(SIGCHLD, SIG_IGN);
    signal(SIGHUP, SIG_IGN);
'''
new_init = '''    signal(SIGCHLD, SIG_IGN);
    signal(SIGHUP, SIG_IGN);
    signal(SIGUSR1, lindows_screen_signal);
'''
if old_init not in text:
    raise SystemExit("signal init marker not found")
text = text.replace(old_init, new_init, 1)

old_root = '''    root = DefaultRootWindow(dpy);
    vis = DefaultVisual(dpy, scr);
'''
new_root = '''    root = DefaultRootWindow(dpy);
    /* Receive root ConfigureNotify when the X screen is resized by RandR. */
    XSelectInput(dpy, root, StructureNotifyMask | PropertyChangeMask);
    vis = DefaultVisual(dpy, scr);
'''
if old_root not in text:
    raise SystemExit("root init marker not found")
text = text.replace(old_root, new_root, 1)

old_switch = '''            switch (ev.type) {
            case Expose:
'''
new_switch = '''            switch (ev.type) {
            case ConfigureNotify:
                if (ev.xconfigure.window == root)
                    lindows_relayout_screen();
                break;
            case Expose:
'''
if old_switch not in text:
    raise SystemExit("event switch marker not found")
text = text.replace(old_switch, new_switch, 1)

old_loop = '''    for (;;) {
        while (XPending(dpy)) {
'''
new_loop = '''    for (;;) {
        if (lindows_screen_dirty) {
            lindows_screen_dirty = 0;
            lindows_relayout_screen();
        }
        while (XPending(dpy)) {
'''
if old_loop not in text:
    raise SystemExit("main loop marker not found")
text = text.replace(old_loop, new_loop, 1)
path.write_text(text)
print(f"patched {path}")
