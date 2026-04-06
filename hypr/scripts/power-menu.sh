#!/bin/bash

option=$(echo -e "lock\nreboot\nshutdown\nlogout" | wofi --dmenu -p "Power")

case "$option" in
    lock)
        hyprlock
        ;;
    logout)
        hyprctl dispatch exit
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
esac
