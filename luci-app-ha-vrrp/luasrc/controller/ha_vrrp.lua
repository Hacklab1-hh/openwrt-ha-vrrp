module("luci.controller.ha_vrrp", package.seeall)

function index()
  if not nixio.fs.access("/etc/config/ha_vrrp") then return end

  local e = entry({"admin","services","ha_vrrp"}, alias("admin","services","ha_vrrp","overview"), _("HA VRRP"), 60)
  e.dependent = true

  entry({"admin","services","ha_vrrp","overview"},  cbi("ha_vrrp/overview"),  _("Overview"),       10).leaf = true
  entry({"admin","services","ha_vrrp","instances"}, cbi("ha_vrrp/instances"), _("Instances"),      20).leaf = true
  entry({"admin","services","ha_vrrp","sync"},      cbi("ha_vrrp/sync"),      _("Sync und Keys"),  30).leaf = true
  entry({"admin","services","ha_vrrp","settings"},  cbi("ha_vrrp/settings"),  _("Settings"),       40).leaf = true

  entry({"admin","services","ha_vrrp","api","status"}, call("api_status")).leaf = true
end

function api_status()
  local http = require "luci.http"
  local sys  = require "luci.sys"
  local uci  = require "luci.model.uci".cursor()

  local peer = uci:get("ha_vrrp","core","peer_host") or ""
  local ping_ok = false
  if peer ~= "" then
    local rc = sys.call("ping -c1 -W1 "..peer.." >/dev/null 2>&1")
    ping_ok = (rc == 0)
  end

  http.prepare_content("application/json")
  http.write_json({ ok=true, ts=os.time(), peer=peer, ping=ping_ok })
end
