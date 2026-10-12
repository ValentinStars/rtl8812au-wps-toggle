#!/usr/bin/env bash
# ==============================================================================
# Uninstaller for RTL8812AU WPS Hardware Toggle Suite
# ==============================================================================

set -e

echo -e "\e[1;33m[*] Uninstalling RTL8812AU WPS Hardware Toggle Suite...\e[0m"

if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31m[-] Please run as root: sudo ./uninstall.sh\e[0m"
    exit 1
fi

rm -f /usr/local/bin/rtl8812au-toggle
rm -f /usr/local/bin/wps-toggle
rm -f /usr/local/bin/rtl8812au-monitor-helper
rm -f /etc/sudoers.d/99-rtl8812au-toggle
rm -f /etc/udev/rules.d/99-rtl8812au-usb.rules
udevadm control --reload-rules

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
    sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user disable --now rtl8812au-wps-listener.service 2>/dev/null || true
    rm -f "$USER_HOME/.config/systemd/user/rtl8812au-wps-listener.service"
    rm -f "$USER_HOME/.local/share/applications/rtl8812au-toggle.desktop"
    sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user daemon-reload 2>/dev/null || true
fi

echo -e "\e[1;32m[✓] Uninstalled cleanly.\e[0m"
