# 🛰️ RTL8812AU Hardware WPS Button Toggle Suite

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
[![Linux Kernel](https://img.shields.io/badge/Kernel-6.x%20--%207.x%2B-blue.svg)](https://kernel.org)
[![Platform](https://img.shields.io/badge/Platform-Arch%20%7C%20Manjaro%20%7C%20Debian%20%7C%20Kali-brightgreen.svg)]()

> **The physical push-button hardware trigger for Realtek RTL8812AU (802.11a/b/g/n/ac 2T2R Dual-Band) wireless adapters on Linux.**

Transform your USB wireless dongle into a physical hardware switch between **Everyday High-Speed Internet** and **Battle-Ready 802.11 Penetration Testing Mode**.

```text
  ██████╗ ████████╗██╗     ██████╗  █████╗  ██╗██████╗  █████╗ ██╗   ██╗
  ██╔══██╗╚══██╔══╝██║     ╚════██╗██╔══██╗███║╚════██╗██╔══██╗██║   ██║
  ██████╔╝   ██║   ██║      █████╔╝╚█████╔╝╚██║ █████╔╝███████║██║   ██║
  ██╔══██╗   ██║   ██║     ██╔═══╝ ██╔══██╗ ██║██╔═══╝ ██╔══██║██║   ██║
  ██║  ██║   ██║   ███████╗███████╗╚█████╔╝ ██║███████╗██║  ██║╚██████╔╝
       ═════ RTL8812AU HARDWARE PENTEST TOGGLE // VST EDITION ═════
```

---

## ⚡ The Discovery Story: Pure Hardware Reverse Engineering

Under standard Linux distributions, the physical plastic push-button on Realtek USB dongles (Alfa AWUS036ACH, TP-Link Archer T4U, ASUS USB-AC56, etc.) **does not exist as an input device**. It does not generate `evdev` keyboard events, udev interrupts, or ACPI triggers because it is an internal ASIC GPIO pin.

By reverse-engineering Realtek's USB control transfers (`bmRequestType=0xC0`, `bRequest=0x05`) across hundreds of registers:
1. Register `0x0042` was found to correlate with the **WLAN Activity LED** (oscillating during packet transfers).
2. **Register `0x0044`, Bit 2 (`0x04`)** was isolated as the **pure hardware button register**:
   * **Released**: `0x00` (100% clean, zero false positives even under heavy multi-gigabit traffic).
   * **Pressed**: `0x04` (`00000100` in binary).

This suite reads register `0x0044` directly over USB Endpoint 0 in userspace using `libusb` / `pyusb` without requiring any kernel out-of-tree re-compilations, taking only **~0.001% CPU**!

---

## 🎯 Features

* 🔘 **Physical Hardware Push Button**: Click the button on the dongle to toggle modes in real time.
* 🌐 **Zero NetworkManager Interruption**: Isolates *only* the RTL8812AU dongle into `unmanaged`. Your laptop's internal Wi-Fi card stays connected to the internet without a single dropped packet!
* 🦈 **Live Wireshark Sniffing**: Automatically launches Wireshark capturing raw 802.11 frames with `-k -i <iface>`.
* 🐱 **Kitty Cyber Console**: Launches an interactive Kitty terminal with:
  * Full interface & MAC diagnostics.
  * Conflict checks.
  * `aircrack-ng --help` pre-executed.
  * Custom cyberpunk terminal prompt `┌──[PENTEST]─[$iface]─[MONITOR]`.
  * Fully compatible with existing `~/.hi` / motd greeting scripts via `SKIP_HI=1`.
* 🔔 **Interactive Feedback**:
  * Desktop notifications via `notify-send`.
  * Audio cues (`device-added.oga` and `device-removed.oga`).
  * ThinkPad LED pulse (ThinkLight / Lid Logo dot blink).
* 🔄 **Clean Two-Way Toggle**: Pressing the WPS button a second time:
  * Gracefully closes Wireshark and Kitty.
  * Restores interface back to `managed` mode.
  * Re-attaches to NetworkManager instantly.

---

## 🚀 Installation

```bash
git clone https://github.com/ValentinStars/rtl8812au-wps-toggle.git /opt/rtl8812au-wps-toggle
cd /opt/rtl8812au-wps-toggle
sudo ./install.sh
```

### Dependencies
* Linux Kernel 6.x / 7.x (with native `rtw88_8812au` or `8812au`)
* `python-pyusb`
* `aircrack-ng`
* `wireshark-qt`
* `kitty`
* `libnotify` (`notify-send`)

On Arch / Manjaro:
```bash
sudo pacman -S python-pyusb aircrack-ng wireshark-qt kitty libnotify
```

---

## ⚙️ Manual CLI Usage

You can also trigger the toggle anytime without touching the hardware button:

```bash
# Toggle modes from terminal:
rtl8812au-toggle

# Or using the alias:
wps-toggle
```

Or bind it to any keyboard shortcut in your desktop environment (KDE Plasma: `System Settings -> Shortcuts -> RTL8812AU Pentest Toggle`).

---

## 📜 License

Released under the [MIT License](LICENSE).
Author: Valentin (ValentinStars)
