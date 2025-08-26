local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()

local m = Map("ha_vrrp", translate("HA VRRP"))

local s = m:section(SimpleSection, translate("Cluster-Status"))
local peer = uci:get("ha_vrrp","core","peer_host") or ""
local cluster = uci:get("ha_vrrp","core","cluster_name") or "-"
local key_type = uci:get("ha_vrrp","core","key_type") or "auto"
local sync_method = uci:get("ha_vrrp","core","sync_method") or "auto"
local ssh_backend = uci:get("ha_vrrp","core","ssh_backend") or "auto"
local priority = uci:get("ha_vrrp","core","priority") or "150"
local version = uci:get("ha_vrrp","core","cluster_version") or "-"
local ping_ok = false
if peer ~= "" then
  local rc = sys.call("ping -c1 -W1 "..peer.." >/dev/null 2>&1")
  ping_ok = (rc == 0)
end

s.template = "ha_vrrp/overview"

m.uci = {
  peer = peer,
  cluster = cluster,
  key_type = key_type,
  sync_method = sync_method,
  ssh_backend = ssh_backend,
  priority = priority,
  version = version,
  ping_ok = ping_ok and "reachable" or "unreachable"
}

local psec = m:section(TypedSection, "discover", translate("Peer Discovery"))
psec.anonymous = true
local ifc = psec:option(ListValue, "iface", translate("Interface"))
ifc:value("HEARTBEAT", "HEARTBEAT")
ifc:value("ADMINLAN", "ADMINLAN")
ifc:value("LAN", "LAN")
ifc.default = "HEARTBEAT"
local run = psec:option(Button, "_run_discover", translate("Discover"))
run.inputstyle="apply"
function run.write(self, section, value)
  local iface = ifc:formvalue(section) or "HEARTBEAT"
  local rc = sys.call(string.format("/usr/libexec/ha-vrrp/discover.sh %q > /tmp/ha_vrrp_discover.json 2>&1", iface))
  luci.http.redirect(luci.dispatcher.build_url("admin/services/ha_vrrp/overview"))
end

return m
