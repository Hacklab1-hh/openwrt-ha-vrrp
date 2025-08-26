local uci = require "luci.model.uci".cursor()
local m = Map("ha_vrrp", translate("Setup Wizard"))

local s = m:section(NamedSection, "core", "core", translate("Cluster Basics"))
local o

o = s:option(Value, "cluster_name", translate("Cluster Name")); o.placeholder = "YOURCLUSTER"
o = s:option(Value, "peer_host", translate("Peer Host (IP/Name)")); o.placeholder = "192.168.254.2"; o.datatype = "host"
o = s:option(ListValue, "key_type", translate("Preferred Key Type")); o:value("auto","auto"); o:value("ed25519","ed25519"); o:value("rsa","rsa")

local t = m:section(TypedSection, "instance", translate("Create First Instance"))
t.addremove = true; t.template = "cbi/tsection"; t.anonymous = true

local name = t:option(Value, "name", translate("Name")); name.datatype = "uciname"; name.placeholder="vrrp0"
local iface = t:option(Value, "interface", translate("Interface")); iface.placeholder="ADMINLAN"
local vip   = t:option(Value, "vip", translate("Virtual IP (CIDR)")); vip.placeholder="192.168.1.254/24"
local vrid  = t:option(Value, "vrid", translate("VRID")); vrid.placeholder="51"
local state = t:option(ListValue, "state", translate("State")); state:value("MASTER","MASTER"); state:value("BACKUP","BACKUP")
local prio  = t:option(Value, "priority", translate("Priority")); prio.placeholder="150"

return m
