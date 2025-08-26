local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()

local m = Map("ha_vrrp", translate("HA VRRP"))
local s = m:section(SimpleSection, translate("Cluster Overview"))
s.template = "ha_vrrp/overview"
return m
