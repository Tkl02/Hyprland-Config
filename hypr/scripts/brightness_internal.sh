#!/bin/bash

STEP=10

if [ "$1" = "up" ]; then
    brightnessctl set +${STEP}%
elif [ "$1" = "down" ]; then
    brightnessctl set ${STEP}%-
fi
