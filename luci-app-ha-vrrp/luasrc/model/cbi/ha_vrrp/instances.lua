-- PATH: luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/instances.lua
local m = Map("ha_vrrp", translate("VRRP Instances"))
local s = m:section(TypedSection, "instance", translate("Instanzen"))
s.addremove = true
s.anonymous = true

local o
o = s:option(Value, "name", translate("Name"))
o.datatype = "uciname"
o.placeholder = "inst_51"

-- Wichtig: ha-vrrp-apply erwartet 'iface' (nicht 'interface')
o = s:option(Value, "iface", translate("Interface"))
o.placeholder = "wan / ADMINLAN"

-- Wichtig: ha-vrrp-apply erwartet 'vip_cidr' (nicht 'vip')
o = s:option(Value, "vip_cidr", translate("Virtual IP (CIDR)"))
o.placeholder = "192.168.1.254/24"

o = s:option(Value, "vrid", translate("VRID"))
o.datatype = "and(uinteger,min(1),max(254))"
o.placeholder = "51"

o = s:option(ListValue, "state", translate("State"))
o:value("MASTER", "MASTER")
o:value("BACKUP", "BACKUP")

o = s:option(Value, "priority", translate("Priority"))
o.datatype = "uinteger"
o.placeholder = "150"

-- Unicast-Pflichtfelder für Apply:
o = s:option(Value, "unicast_src_ip", translate("Unicast Source IP"))
o.placeholder = "192.168.1.2"

local p = s:option(DynamicList, "unicast_peer", translate("Unicast Peers (IP)"))
p.placeholder = "192.168.1.3"

return m

