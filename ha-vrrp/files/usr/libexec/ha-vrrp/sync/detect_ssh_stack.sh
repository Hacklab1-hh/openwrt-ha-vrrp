#!/bin/sh
if command -v ssh >/dev/null 2>&1 && ssh -V 2>&1 | grep -qi openssh; then echo openssh
elif command -v dbclient >/dev/null 2>&1 || command -v dropbearkey >/dev/null 2>&1; then echo dropbear
else echo none; fi
