#!/usr/bin/env bash

export HUGO_SECURITY_EXEC_ALLOW="^(dart-sass-embedded|go|npx|postcss|nvim)$"
hugo new blog/$(date +%F)-$1.md --editor nvim
