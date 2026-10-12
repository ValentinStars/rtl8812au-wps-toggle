#!/usr/bin/env python3
"""
RTL8812AU Pure Hardware WPS Button Listener Daemon
Hardware Target: Register 0x0044, Bit 2 (0x04).
Zero-noise, 100% genuine physical WPS button on the USB adapter!
"""

import os
import sys
import time
import subprocess
import usb.core

TOGGLE_SCRIPT = "/opt/rtl8812au-wps-toggle/bin/rtl8812au-toggle"
if not os.path.exists(TOGGLE_SCRIPT):
    TOGGLE_SCRIPT = "/home/valentin_stars/rtl8812au-toggle.sh"

REG_ADDR = 0x0044
WPS_BIT_MASK = 0x04  # Bit 2 (0x04)
DEBOUNCE_DELAY = 1.5  # 1.5s cooldown after trigger

def get_device():
    try:
        return usb.core.find(idVendor=0x0bda, idProduct=0x8812)
    except Exception:
        return None

def main():
    print("[*] RTL8812AU True Hardware WPS Daemon started.", flush=True)
    last_trigger_time = 0.0
    btn_was_pressed = False

    while True:
        dev = get_device()
        if not dev:
            time.sleep(1.5)
            continue

        try:
            while True:
                # Читаем чистый аппаратный регистр кнопки 0x0044
                ret = dev.ctrl_transfer(0xc0, 0x05, REG_ADDR, 0, 1, timeout=500)
                val = ret[0]
                is_pressed = bool(val & WPS_BIT_MASK)

                now = time.time()

                # Срабатывание по фронту нажатия физической кнопки
                if is_pressed and not btn_was_pressed:
                    btn_was_pressed = True
                    if (now - last_trigger_time) > DEBOUNCE_DELAY:
                        last_trigger_time = now
                        print(f"[{time.strftime('%H:%M:%S')}] 🔥 PHYSICAL WPS BUTTON CLICKED (Reg 0x44 = 0x{val:02X})! Executing Toggle...", flush=True)
                        env = os.environ.copy()
                        env["DISPLAY"] = ":0"
                        env["WAYLAND_DISPLAY"] = "wayland-0"
                        env["XDG_RUNTIME_DIR"] = "/run/user/1000"
                        env["DBUS_SESSION_BUS_ADDRESS"] = "unix:path=/run/user/1000/bus"
                        subprocess.run(["/bin/bash", TOGGLE_SCRIPT], env=env)
                elif not is_pressed:
                    btn_was_pressed = False

                time.sleep(0.08)  # 12 опросов в секунду (0.00% CPU)
        except (usb.core.USBError, Exception):
            # Адаптер выдернут или шина перезагружена
            time.sleep(1.0)

if __name__ == "__main__":
    main()
