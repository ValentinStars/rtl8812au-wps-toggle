#!/usr/bin/env bash
# ==============================================================================
# Installer for RTL8812AU WPS Hardware Toggle Suite
# ==============================================================================

set -e

INSTALL_DIR="/opt/rtl8812au-wps-toggle"

echo -e "\e[1;36m[*] Installing RTL8812AU WPS Hardware Toggle Suite...\e[0m"

# 1. Check permissions
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31m[-] Please run as root: sudo ./install.sh\e[0m"
    exit 1
fi

# 2. Permissions on binaries
chmod +x "$INSTALL_DIR/bin/rtl8812au-toggle"
chmod +x "$INSTALL_DIR/bin/rtl8812au-monitor-helper"
chmod +x "$INSTALL_DIR/daemon/rtl8812au-wps-daemon.py"

# 3. Symlink binaries to PATH
ln -sf "$INSTALL_DIR/bin/rtl8812au-toggle" /usr/local/bin/rtl8812au-toggle
ln -sf "$INSTALL_DIR/bin/rtl8812au-toggle" /usr/local/bin/wps-toggle
ln -sf "$INSTALL_DIR/bin/rtl8812au-monitor-helper" /usr/local/bin/rtl8812au-monitor-helper

# 4. Install sudoers rule
cp "$INSTALL_DIR/sudoers/99-rtl8812au-toggle" /etc/sudoers.d/99-rtl8812au-toggle
chmod 0440 /etc/sudoers.d/99-rtl8812au-toggle

# 5. Install udev rule
cp "$INSTALL_DIR/udev/99-rtl8812au-usb.rules" /etc/udev/rules.d/99-rtl8812au-usb.rules
udevadm control --reload-rules
udevadm trigger --subsystem-match=usb

# 6. Install desktop launcher
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
    mkdir -p "$USER_HOME/.local/share/applications"
    mkdir -p "$USER_HOME/.config/systemd/user"
    cp "$INSTALL_DIR/desktop/rtl8812au-toggle.desktop" "$USER_HOME/.local/share/applications/"
    cp "$INSTALL_DIR/systemd/rtl8812au-wps-listener.service" "$USER_HOME/.config/systemd/user/"
    chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.local/share/applications/rtl8812au-toggle.desktop"
    chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.config/systemd/user/rtl8812au-wps-listener.service"
    
    # Reload and enable user systemd service
    sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user daemon-reload
    sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user enable --now rtl8812au-wps-listener.service
fi

echo -e "\e[1;32m[✓] Installation successful!\e[0m"
echo -e "\e[1;32m[✓] Daemon active: rtl8812au-wps-listener.service\e[0m"
echo -e "\e[1;32m[✓] Commands available: rtl8812au-toggle, wps-toggle\e[0m"
