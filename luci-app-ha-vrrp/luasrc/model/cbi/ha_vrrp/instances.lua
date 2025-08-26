local m = Map("ha_vrrp", translate("VRRP Instances"))
local s = m:section(TypedSection, "instance", translate("Instanzen"))
s.addremove = true
s.anonymous = true

local o
o = s:option(Value, "name", translate("Name"))
o.datatype = "uciname"

o = s:option(Value, "interface", translate("Interface"))
o.placeholder = "ADMINLAN"

o = s:option(Value, "vip", translate("Virtual IP"))
o.placeholder = "192.168.1.254/24"

o = s:option(Value, "vrid", translate("VRID"))
o.placeholder = "51"

o = s:option(ListValue, "state", translate("State"))
o:value("MASTER", "MASTER")
o:value("BACKUP", "BACKUP")

o = s:option(Value, "priority", translate("Priority"))
o.datatype = "uinteger"
o.placeholder = "150"

return m
