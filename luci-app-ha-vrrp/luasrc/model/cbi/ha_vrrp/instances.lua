local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()

local m = Map("ha_vrrp", translate("VRRP Instances"))
local s = m:section(TypedSection, "instance", translate("Instances"))
s.addremove = true
s.anonymous = true

function s.create(self, section)
  local sid = TypedSection.create(self, section)
  uci:set("ha_vrrp", sid, "priority", "150")
  uci:save("ha_vrrp"); uci:commit("ha_vrrp")
  return sid
end

local o
o = s:option(Value, "name", translate("Name"))
o.datatype = "uciname"
o.rmempty = false

local ifc = s:option(ListValue, "interface", translate("Interface"))
ifc.placeholder = "ADMINLAN"
for _, dev in ipairs(sys.net.devices() or {}) do
  if dev ~= "lo" then ifc:value(dev) end
end

local vip = s:option(Value, "vip", translate("Virtual IP (CIDR)"))
vip.placeholder = "192.168.1.254/24"
vip.datatype = "ip4addr"
function vip.validate(self, value, section)
  if not value or value == "" then return nil, translate("Virtual IP required") end
  if not value:match("/%d+$") then return nil, translate("Please use CIDR notation, e.g. 192.168.1.254/24") end
  return Value.validate(self, value, section)
end

local vrid = s:option(Value, "vrid", translate("VRID"))
vrid.placeholder = "51"
vrid.datatype = "range(1,255)"

local state = s:option(ListValue, "state", translate("State"))
state:value("MASTER", "MASTER")
state:value("BACKUP", "BACKUP")

local prio = s:option(Value, "priority", translate("Priority"))
prio.datatype = "uinteger"
prio.placeholder = "150"

return m
