#!/usr/bin/env python3
"""Patch the Lindows ElevenDE shell to relayout after RandR changes."""
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: patch-elevende-shell-display.py PATH_TO_MAIN_C")
path = Path(sys.argv[1])
text = path.read_text()

include_marker = "#include <X11/Xutil.h>\n"
include_replacement = include_marker + "#include <X11/extensions/Xrandr.h>\n"
if "#include <X11/extensions/Xrandr.h>" not in text:
    if include_marker not in text:
        raise SystemExit("Xutil include marker not found")
    text = text.replace(include_marker, include_replacement, 1)

old_decl = "static Window mk_owindow(int x, int y, int w, int h);\n"
new_decl = old_decl + (
    "static void set_wm_state(Window w);\n"
    "static void power_hide(void);\n"
    "static volatile sig_atomic_t lindows_screen_dirty = 0;\n"
    "static void lindows_screen_signal(int sig) { (void)sig; lindows_screen_dirty = 1; }\n"
)
if old_decl not in text:
    raise SystemExit("window declaration marker not found")
if "lindows_screen_dirty" not in text:
    text = text.replace(old_decl, new_decl, 1)

marker = "/* ---------------------------------------------------------------- windows */\n"
helper = '''/* Recompute all shell-owned geometry after an XRandR mode change.  XWidthOfScreen
 * can remain stale on some X servers, so prefer the current RandR mode size. */
static void lindows_screen_dimensions(int *out_w, int *out_h) {
    int w = XWidthOfScreen(ScreenOfDisplay(dpy, scr));
    int h = XHeightOfScreen(ScreenOfDisplay(dpy, scr));
    XRRScreenConfiguration *cfg = XRRGetScreenInfo(dpy, root);
    if (cfg) {
        Rotation rotation = RR_Rotate_0;
        SizeID current = XRRConfigCurrentConfiguration(cfg, &rotation);
        int count = 0;
        XRRScreenSize *sizes = XRRConfigSizes(cfg, &count);
        if (sizes && current < (SizeID)count) {
            w = sizes[current].width;
            h = sizes[current].height;
        }
        XRRFreeScreenConfigInfo(cfg);
    }
    *out_w = w;
    *out_h = h;
}

static void lindows_relayout_screen(void) {
    int nw = 0, nh = 0;
    lindows_screen_dimensions(&nw, &nh);
    if (nw <= 0 || nh <= 0)
        return;
    scr_w = nw;
    scr_h = nh;
    if (win_bar) {
        XMoveResizeWindow(dpy, win_bar, 0, scr_h - BAR_H, scr_w, BAR_H);
        edge_r = (RRect){ scr_w - 9, 0, 9, BAR_H };
        clock_r = (RRect){ scr_w - 9 - 92, 0, 88, BAR_H };
        im_r = (RRect){ clock_r.x - 4 - 44, (BAR_H - 36) / 2, 44, 36 };
        pill_r = (RRect){ im_r.x - 4 - 82, (BAR_H - 36) / 2, 82, 36 };
        net_r = (RRect){ pill_r.x + 4, pill_r.y, 26, pill_r.h };
        set_wm_state(win_bar);
    }
    if (win_desk) {
        XMoveResizeWindow(dpy, win_desk, 0, 0, scr_w, scr_h - BAR_H);
        Atom below = atom("_NET_WM_STATE_BELOW");
        XChangeProperty(dpy, win_desk, atom("_NET_WM_STATE"), XA_ATOM, 32,
                        PropModeReplace, (unsigned char *)&below, 1);
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
    XClearArea(dpy, win_desk, 0, 0, 0, 0, True);
    XClearArea(dpy, win_bar, 0, 0, 0, 0, True);
    XRaiseWindow(dpy, win_bar);
    XFlush(dpy);
}

'''
if marker not in text:
    raise SystemExit("window section marker not found")
if "static void lindows_relayout_screen(void)" not in text:
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
if "signal(SIGUSR1, lindows_screen_signal);" not in text:
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
if "XSelectInput(dpy, root, StructureNotifyMask | PropertyChangeMask);" not in text:
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
if "case ConfigureNotify:" not in text:
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
if "if (lindows_screen_dirty)" not in text:
    text = text.replace(old_loop, new_loop, 1)

path.write_text(text)
print(f"patched {path}")
