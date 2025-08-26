local m = Map("ha_vrrp", translate("HA VRRP"), translate(
  "VRRP (Keepalived) with optional VLAN per instance (Unicast). Multi-instance supported (edit via UCI)."
))

local s = m:section(NamedSection, "core", "core", translate("Core"))

s:option(Flag, "enabled", translate("Enabled")).default = "1"
s:option(Value, "cluster_name", translate("Cluster Name")).rmempty=false
local pass = s:option(Value, "auth_pass", translate("Auth PASS")); pass.password=true

-- NOTE: Instances can be created via UCI. A richer multi-instance UI can be added later.

return m
