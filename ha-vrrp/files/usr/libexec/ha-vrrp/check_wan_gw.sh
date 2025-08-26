#!/bin/sh
IF="$1"; [ -n "$IF" ] || exit 1
GW="$(ubus call network.interface.$IF status 2>/dev/null | jsonfilter -e '@.route[0].nexthop' | head -n1)"
[ -n "$GW" ] && [ "$GW" != "null" ] || GW="$(ip route show dev "$IF" 0.0.0.0/0 | awk '/default/ {print $3; exit}')"
[ -n "$GW" ] || exit 1
ping -c1 -W1 "$GW" >/dev/null 2>&1
exit $?
