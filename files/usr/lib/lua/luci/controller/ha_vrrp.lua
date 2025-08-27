--[[
LuCI Controller for HA VRRP
Compatible with OpenWrt 19.07+ (classic CBI)
Provides menu entries and an action endpoint to trigger helper scripts.
]]
module("luci.controller.ha_vrrp", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/ha_vrrp") then
        return
    end
    local page = entry({"admin","services","ha_vrrp"}, firstchild(), _("HA VRRP"), 60)
    page.dependent = true

    entry({"admin","services","ha_vrrp","overview"}, template("ha_vrrp/overview"), _("Overview"), 1)
    entry({"admin","services","ha_vrrp","general"}, cbi("ha_vrrp/general"), _("General"), 2).leaf = true
    entry({"admin","services","ha_vrrp","peers"}, cbi("ha_vrrp/peers"), _("Peers & Sync"), 3).leaf = true

    -- Action endpoint for running helper scripts (returns JSON).
    entry({"admin","services","ha_vrrp","action"}, call("action_run"), nil, 10).leaf = true
end

function action_run()
    local http = require "luci.http"
    local util = require "luci.util"
    local sys  = require "luci.sys"
    local cmd  = http.formvalue("cmd") or ""
    local map = {
        ["apply"]        = "/usr/sbin/ha-vrrp-apply",
        ["ensure-vlan"]  = "/usr/libexec/ha-vrrp/ensure_vlan.sh",
        ["keys-gen"]     = "/usr/libexec/ha-vrrp/keysync.sh gen",
        ["keys-push"]    = "/usr/libexec/ha-vrrp/keysync.sh push",
        ["sync-push"]    = "/usr/sbin/ha-vrrp-sync push",
        ["discover"]     = "/usr/libexec/ha-vrrp/discover_peers.sh",
        ["restart"]      = "/etc/init.d/ha-vrrp restart"
    }
    local shell = map[cmd]
    local rc, out = 1, ""
    if shell then
        out = util.exec(shell .. " 2>&1")
        rc = 0
    end
    http.prepare_content("application/json")
    http.write_json({ ok = (rc == 0), cmd = cmd, output = out })
end
