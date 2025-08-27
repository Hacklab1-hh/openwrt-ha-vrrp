--[[
CBI model: Peers & Sync
Configure peer node, SSH, and watched paths for autosync.
]]
local sys = require "luci.sys"
local util = require "luci.util"

m = Map("ha_vrrp", translate("HA VRRP — Peers & Sync"),
    translate("Define peer node and file sync parameters."))

s = m:section(NamedSection, "core", "core", translate("Peer"))
s.addremove = false
s.anonymous = true

ph = s:option(Value, "peer_host", translate("Peer hostname/IP"))
ph.placeholder = "192.0.2.11"
ph.datatype = "host"

pu = s:option(Value, "peer_user", translate("Peer SSH user"))
pu.default = "root"

pp = s:option(Value, "peer_port", translate("Peer SSH port"))
pp.datatype = "port"
pp.default = 22

pm = s:option(Value, "peer_netmask_cidr", translate("Peer link netmask (CIDR)"))
pm.datatype = "range(0,32)"
pm.default = 24

sp = s:option(DynamicList, "sync_path", translate("Watched files (autosync)"))
sp.placeholder = "/etc/config/network"

-- Inline help
sp.description = translate("When autosync is enabled, an md5 sum across these files triggers a push to the peer.")

return m
