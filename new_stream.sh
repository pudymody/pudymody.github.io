#!/usr/bin/env bash

export HUGO_SECURITY_EXEC_ALLOW="^(dart-sass-embedded|go|npx|postcss|nvim)$"
hugo new stream/$(date +%F_%H-%M).md --editor nvim
