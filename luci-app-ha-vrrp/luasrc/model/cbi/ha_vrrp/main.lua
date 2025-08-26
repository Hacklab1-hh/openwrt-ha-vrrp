local m = Map("ha_vrrp", translate("HA VRRP"),
  translate("VRRP (Keepalived) with multi-instance, VLAN-HB, peer sync/discovery, health checks, autosync.")
)

local s = m:section(NamedSection, "core", "core", translate("Core"))
s:option(Flag, "enabled", translate("Enabled")).default = "1"
s:option(Value, "cluster_name", translate("Cluster Name")).rmempty=false
local pass = s:option(Value, "auth_pass", translate("Auth PASS")); pass.password=true

-- Peer settings (sync/status)
s:option(Value, "peer_host", translate("Peer Host (HEARTBEAT IP)")).rmempty=false
local u = s:option(Value, "peer_user", translate("Peer SSH user")); u.default="root"
local p = s:option(Value, "peer_port", translate("Peer SSH port")); p.default="22"

-- Sync files + autosync
local sp = s:option(DynamicList, "sync_path", translate("Sync paths"))
sp:value("/etc/config/ha_vrrp"); sp:value("/etc/config/network"); sp:value("/etc/config/firewall")
local as = s:option(Flag, "auto_sync", translate("Auto Sync daemon")); as.default="0"
local ai = s:option(Value, "auto_sync_interval", translate("Auto Sync interval (s)")); ai.default="7"

-- Discovery
s:option(Value, "discover_cidr", translate("Discovery CIDR (override)")).placeholder="192.168.254.0/24"
local dmin = s:option(Value, "discover_min", translate("Discovery start host")); dmin.default="1"
local dmax = s:option(Value, "discover_max", translate("Discovery end host")); dmax.default="10"

-- Health v4
local hi = s:option(DynamicList, "health_wan_if", translate("Health: IPv4 WAN ifaces"))
hi.placeholder="wan"
local iv = s:option(Value, "health_interval", translate("IPv4: interval (s)")); iv.default="2"
local fl = s:option(Value, "health_fall", translate("IPv4: fall")); fl.default="2"
local rs = s:option(Value, "health_rise", translate("IPv4: rise")); rs.default="2"
local wt = s:option(Value, "health_weight", translate("IPv4: weight on fail")); wt.default="-30"

-- Health v6
local h6 = s:option(DynamicList, "health_wan6_if", translate("Health: IPv6 WAN ifaces"))
h6.placeholder="wan6"
local i6 = s:option(Value, "health6_interval", translate("IPv6: interval (s)")); i6.default="3"
local f6 = s:option(Value, "health6_fall", translate("IPv6: fall")); f6.default="2"
local r6 = s:option(Value, "health6_rise", translate("IPv6: rise")); r6.default="2"
local w6 = s:option(Value, "health6_weight", translate("IPv6: weight on fail")); w6.default="-20"

return m
