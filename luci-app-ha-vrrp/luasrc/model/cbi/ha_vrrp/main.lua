local m = Map("ha_vrrp", translate("HA VRRP"), translate("VRRP with multi-instance + peer sync + discovery."))
local s = m:section(NamedSection, "core", "core", translate("Core"))
s:option(Flag, "enabled", translate("Enabled")).default = "1"
s:option(Value, "cluster_name", translate("Cluster Name")).rmempty=false
local pass = s:option(Value, "auth_pass", translate("Auth PASS")); pass.password=true
s:option(Value, "peer_host", translate("Peer Host (HEARTBEAT IP)")).rmempty=false
local u = s:option(Value, "peer_user", translate("Peer SSH user")); u.default="root"
local p = s:option(Value, "peer_port", translate("Peer SSH port")); p.default="22"
local sp = s:option(DynamicList, "sync_path", translate("Sync paths"))
sp:value("/etc/config/ha_vrrp"); sp:value("/etc/config/network"); sp:value("/etc/config/firewall")
return m
