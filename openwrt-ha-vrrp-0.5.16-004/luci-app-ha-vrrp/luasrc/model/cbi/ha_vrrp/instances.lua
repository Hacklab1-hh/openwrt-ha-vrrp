local m = Map("ha_vrrp", translate("Instances"))
local s = m:section(SimpleSection, translate("Instanzen Übersicht"))
s.template = "ha_vrrp/instances"
return m
