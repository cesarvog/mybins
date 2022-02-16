#!/bin/bash

export SFEED_URL_FILE=$HOME/.config/sfeed/urls
[ -f "$SFEED_URL_FILE" ] || touch "$SFEED_URL_FILE"
sfeed_curses $HOME/.config/sfeed/feeds/*

