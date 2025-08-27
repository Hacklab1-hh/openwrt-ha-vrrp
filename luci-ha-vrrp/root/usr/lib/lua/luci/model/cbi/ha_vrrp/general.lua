--[[
CBI model: General settings for HA VRRP
Focuses on core UCI section 'ha_vrrp.core'.
]]
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

m = Map("ha_vrrp", translate("HA VRRP — General"),
    translate("Configure core cluster settings. Changes require Apply/Restart."))

s = m:section(NamedSection, "core", "core", translate("Core"))
s.addremove = false
s.anonymous = true

en = s:option(Flag, "enabled", translate("Enabled"))
en.default = en.enabled
en.rmempty = false

cl = s:option(Value, "cluster_name", translate("Cluster name"))
cl.datatype = "uciname"
cl.default = "lab-ha"

ap = s:option(Value, "auth_pass", translate("Auth password"))
ap.password = true
ap.default = "changeme-please"

-- WAN health (IPv4)
hi = s:option(Value, "health_interval", translate("Health interval (s)"))
hi.datatype = "uinteger"
hi.default = 2

hf = s:option(Value, "health_fall", translate("Health fall (fails)"))
hf.datatype = "uinteger"
hf.default = 2

hr = s:option(Value, "health_rise", translate("Health rise (passes)"))
hr.datatype = "uinteger"
hr.default = 2

-- Auto sync daemon
as = s:option(Flag, "auto_sync", translate("Enable autosync daemon"))
as.default = as.disabled

ai = s:option(Value, "auto_sync_interval", translate("Autosync interval (s)"))
ai.datatype = "uinteger"
ai.default = 7
ai:depends("auto_sync", "1")

-- SSH backend
sb = s:option(ListValue, "ssh_backend", translate("SSH backend"))
sb:value("auto", "auto")
sb:value("dropbear", "dropbear")
sb:value("openssh", "openssh")

-- Optional: interface used for WAN health (show network ifaces)
local nets = sys.net.devices() or {}
hw = s:option(ListValue, "health_wan_if", translate("Health WAN interface"))
hw.default = "wan"
hw.rmempty = true
for _,dev in ipairs(nets) do
    if dev ~= "lo" then hw:value(dev) end
end

return m
