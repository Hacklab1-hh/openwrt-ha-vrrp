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
        entry({"admin","services","ha_vrrp","status"}, template("ha_vrrp/status"), _("Status"), 1)
    entry({"admin","services","ha_vrrp","general"}, cbi("ha_vrrp/general"), _("General"), 2).leaf = true
    entry({"admin","services","ha_vrrp","peers"}, cbi("ha_vrrp/peers"), _("Peers & Sync"), 3).leaf = true

    -- Action endpoint for running helper scripts (returns JSON).
    entry({"admin","services","ha_vrrp","action"}, call("action_run"), nil, 10).leaf = true
end


function action_run()
    local http = require "luci.http"
    local util = require "luci.util"
    local cmd  = http.formvalue("cmd") or ""
    local allowed = {
        ["apply"]=true, ["ensure-vlan"]=true, ["keys-gen"]=true, ["keys-push"]=true,
        ["sync-push"]=true, ["discover"]=true, ["restart"]=true, ["status"]=true, ["status-full"]=true
    }
    if not allowed[cmd] then
        if cmd:match("^log%-tail:%d+$") then
            allowed[cmd] = true
        end
    end
    if not allowed[cmd] then
        http.prepare_content("application/json")
        http.write_json({ ok = false, error = "unknown command" })
        return
    end
    local out = util.exec("/usr/sbin/ha-vrrp-api " .. util.shellquote(cmd) .. " 2>/dev/null")
    http.prepare_content("application/json")
    if out and #out > 0 then http.write(out) else http.write_json({ ok=false, error="no output" }) end
end

