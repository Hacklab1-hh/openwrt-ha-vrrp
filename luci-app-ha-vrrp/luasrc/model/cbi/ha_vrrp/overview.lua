local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()

local m = Map("ha_vrrp", translate("HA VRRP"))

local s = m:section(SimpleSection, translate("Cluster-Status"))
local peer = uci:get("ha_vrrp","core","peer_host") or ""
local cluster = uci:get("ha_vrrp","core","cluster_name") or "-"
local key_type = uci:get("ha_vrrp","core","key_type") or "auto"
local sync_method = uci:get("ha_vrrp","core","sync_method") or "auto"
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
  ping_ok = ping_ok and "reachable" or "unreachable"
}

return m
