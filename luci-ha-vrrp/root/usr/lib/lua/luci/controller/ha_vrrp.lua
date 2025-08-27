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

    -- JSON status endpoint for external monitoring.  Returns a machine‑readable
    -- summary of the add‑on state (version, keepalived status, last migration).
    entry({"admin","services","ha_vrrp","status_json"}, call("action_status_json"), nil, 11).leaf = true
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

--
-- Return the status of the HA VRRP add‑on as JSON.  This helper reads the
-- installed version from /etc/ha-vrrp/version, determines the state of the
-- keepalived process and loads the last migration state from
-- /etc/ha-vrrp/state.json.  The response is minimal and safe to call
-- unauthenticated for use with external systems such as Home Assistant.
function action_status_json()
    local http = require "luci.http"
    local util = require "luci.util"
    local json = require "luci.jsonc"

    -- Determine installed version
    local inst_ver = "unknown"
    local vf = io.open("/etc/ha-vrrp/version", "r")
    if vf then
        inst_ver = vf:read("*l") or inst_ver
        vf:close()
    end

    -- Determine keepalived state
    local keep = "absent"
    if util.exec("command -v keepalived >/dev/null 2>&1 && echo yes || echo no"):match("yes") then
        if util.exec("pidof keepalived >/dev/null 2>&1 && echo run || echo stop"):match("run") then
            keep = "running"
        else
            keep = "installed"
        end
    end

    -- Read last migration state
    local last_step = ""
    local success = false
    local sf = io.open("/etc/ha-vrrp/state.json", "r")
    if sf then
        local content = sf:read("*a") or ""
        sf:close()
        local obj = json.parse(content) or {}
        last_step = obj.last_step or ""
        if obj.success ~= nil then
            success = obj.success and true or false
        end
    end

    http.prepare_content("application/json")
    http.write(json.stringify({
        addon_version = inst_ver,
        keepalived = keep,
        last_migration_step = last_step,
        last_migration_success = success
    }))
end

