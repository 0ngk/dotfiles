# OpenBSD notification center

Files:

- `notification-center`: dunst history browser/controller.
- `notification-center.rasi`: rofi theme.

Requirements:

    doas pkg_add dunst rofi py3-dbus

Install:

    install -d ~/.local/bin ~/.config/rofi
    install -m 755 notification-center ~/.local/bin/notification-center
    install -m 644 notification-center.rasi ~/.config/rofi/notification-center.rasi

Make sure the X11 session has a D-Bus session. For an i3 session started from
`.xsession`, one common arrangement is to launch the session through
`dbus-launch`.

i3 binding:

    bindsym $mod+n exec --no-startup-id ~/.local/bin/notification-center

Controls:

- Enter: restore/show the selected notification.
- Ctrl+D: delete the selected history entry.
- Ctrl+Shift+D: clear all history.
- Ctrl+R: reload history.
- Esc: close the notification center.

The script directly calls dunst's `org.dunstproject.cmd0` interface and does not
depend on `busctl` or `dunstctl history`.
