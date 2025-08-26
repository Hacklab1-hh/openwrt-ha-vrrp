local m = Map("ha_vrrp", translate("HA VRRP"), translate(
  "VRRP (Keepalived) with optional VLAN interface for heartbeat/VIP (Unicast)."
))

local s = m:section(NamedSection, "core", "ha", translate("Core"))

s:option(Flag, "enabled", translate("Enabled")).default = "1"
s:option(Value, "cluster_name", translate("Cluster Name")).rmempty=false
local pass = s:option(Value, "auth_pass", translate("Auth PASS")); pass.password=true

local st = s:option(ListValue, "state", translate("Start state"))
st:value("MASTER","MASTER"); st:value("BACKUP","BACKUP")

local pre = s:option(Flag, "preempt", translate("Preempt (allow takeover)")); pre.default="1"
s:option(Value, "advert_int", translate("Advert interval (s)")).datatype="uinteger"
s:option(Value, "vrid", translate("VRID (0..255)")).datatype="uinteger"
s:option(Value, "priority", translate("Priority")).datatype="uinteger"

s:option(Value, "iface", translate("Base interface"))
s:option(Flag, "use_vlan", translate("Use VLAN")).default="0"
s:option(Value, "vlan_id", translate("VLAN ID"))
s:option(Value, "vip_cidr", translate("VIP (CIDR)")).rmempty=false

s:option(Value, "unicast_src_ip", translate("Unicast source IP")).rmempty=false
local peers = s:option(DynamicList, "unicast_peer", translate("Unicast peers (IPs)"))
peers.placeholder="192.0.2.11"

s:option(Flag, "extra_garp", translate("Send extra GARPs")).default="0"
s:option(Value, "notify_master", translate("Notify Master Script")).default="/usr/libexec/ha-vrrp/notify_master.sh"
s:option(Value, "notify_backup", translate("Notify Backup Script")).default="/usr/libexec/ha-vrrp/notify_backup.sh"

return m
