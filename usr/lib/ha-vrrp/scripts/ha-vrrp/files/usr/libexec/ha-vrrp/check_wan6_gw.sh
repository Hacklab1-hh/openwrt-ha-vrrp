#!/bin/sh
IF="$1"; [ -n "$IF" ] || exit 1
GW="$(ubus call network.interface.$IF status 2>/dev/null | jsonfilter -e '@.route6[0].nexthop' | head -n1)"
[ -n "$GW" ] && [ "$GW" != "null" ] || GW="$(ip -6 route show dev "$IF" default | awk '/default/ {print $3; exit}')"
[ -n "$GW" ] || exit 1
ping -6 -c1 -W1 "$GW" >/dev/null 2>&1
exit $?
