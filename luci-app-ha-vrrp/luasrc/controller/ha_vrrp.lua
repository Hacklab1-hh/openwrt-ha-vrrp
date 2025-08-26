module("luci.controller.ha_vrrp", package.seeall)

local function run(cmd)
  local f = io.popen(cmd .. " 2>/dev/null")
  if not f then return "" end
  local s = f:read("*a") or ""
  f:close()
  return s
end

function index()
  if not nixio.fs.access("/etc/config/ha_vrrp") then return end
  entry({"admin","services","ha_vrrp"}, firstchild(), _("HA VRRP"), 50).dependent = true
  entry({"admin","services","ha_vrrp","status"}, template("ha_vrrp/status"), _("Status"), 1).leaf = true
  entry({"admin","services","ha_vrrp","config"}, cbi("ha_vrrp/main"), _("Konfiguration"), 2).leaf = true
  entry({"admin","services","ha_vrrp","apply"}, call("apply"), nil).leaf = true
  entry({"admin","services","ha_vrrp","discover"}, call("discover"), nil).leaf = true
  entry({"admin","services","ha_vrrp","keysync"}, call("keysync"), nil).leaf = true
  entry({"admin","services","ha_vrrp","sync"}, call("syncpush"), nil).leaf = true
  entry({"admin","services","ha_vrrp","statusjson"}, call("statusjson"), nil).leaf = true
end

function apply()
  local http = require "luci.http"
  local ok = (os.execute("/usr/sbin/ha-vrrp-apply >/tmp/ha_vrrp.out 2>&1") == 0)
  if ok then os.execute("/etc/init.d/keepalived restart >/dev/null 2>&1") end
  http.prepare_content("application/json")
  http.write_json({ ok = ok })
end

function discover()
  local http = require "luci.http"
  local out = run("/usr/libexec/ha-vrrp/discover_peers.sh")
  local list = {}
  for ip in out:gmatch("([%d%.]+)") do list[#list+1] = ip end
  http.prepare_content("application/json")
  http.write_json({ peers = list })
end

function keysync()
  local http = require "luci.http"
  local ok = (os.execute("/usr/sbin/ha-vrrp-sync keysync >/tmp/ha_vrrp_keysync.out 2>&1") == 0)
  http.prepare_content("application/json")
  http.write_json({ ok = ok })
end

function syncpush()
  local http = require "luci.http"
  local ok = (os.execute("/usr/sbin/ha-vrrp-sync push >/tmp/ha_vrrp_sync.out 2>&1") == 0)
  http.prepare_content("application/json")
  http.write_json({ ok = ok })
end

local function dev_for(sec, uci)
  local iface = uci:get("ha_vrrp", sec, "iface") or ""
  local use_vlan = uci:get("ha_vrrp", sec, "use_vlan") or "0"
  local vid = uci:get("ha_vrrp", sec, "vlan_id") or ""
  local dev = iface
  if use_vlan == "1" and vid ~= "" then dev = iface .. "." .. vid end
  return dev
end

local function vip_for(sec, uci)
  local vip = uci:get("ha_vrrp", sec, "vip_cidr") or ""
  if vip == "" then
    local c = io.popen("uci -q show ha_vrrp | awk -F= '/^ha_vrrp\."..sec.."\.vip_list/ {gsub(/\'\'/, "", $2); print $2; exit}'")
    if c then
      local out = c:read("*a") or ""; c:close()
      vip = (out:match("([%d%./]+)")) or ""
    end
  end
  return vip:gsub("/%d+$","")
end

local function vip_present_local(dev, vip)
  local out = run("ip addr show dev " .. dev)
  if out:match("%f[%d]"..vip:gsub("%.","%%.").."%f[^%d]") then return true end
  return false
end

local function vip_present_remote(host, user, port, dev, vip)
  local cmd = string.format("ssh -o StrictHostKeyChecking=no -p %s %s@%s ip addr show dev %s",
    port or "22", user or "root", host, dev)
  local out = run(cmd)
  if out:match("%f[%d]"..vip:gsub("%.","%%.").."%f[^%d]") then return true end
  return false
end

function statusjson()
  local http = require "luci.http"
  local uci = require "luci.model.uci".cursor()

  local host = run("uci -q get system.@system[0].hostname"):gsub("%s+$","")
  local peer_host = uci:get("ha_vrrp","core","peer_host") or ""
  local peer_user = uci:get("ha_vrrp","core","peer_user") or "root"
  local peer_port = uci:get("ha_vrrp","core","peer_port") or "22"

  local instances = {}
  uci:foreach("ha_vrrp", "instance", function(s)
    local sec = s[".name"]
    local name = s.name or sec
    local dev = dev_for(sec, uci)
    local vip = vip_for(sec, uci)
    local local_master = (dev ~= "" and vip ~= "" and vip_present_local(dev, vip)) or false
    instances[#instances+1] = {
      sec = sec, name = name, dev = dev, vip = vip,
      local_master = local_master
    }
  end)

  -- Backward compat: if no explicit instances, synthesize one from 'core' for status view
  if #instances == 0 then
    local dev = dev_for("core", uci)
    local vip = vip_for("core", uci)
    if dev ~= "" or vip ~= "" then
      local local_master = (dev ~= "" and vip ~= "" and vip_present_local(dev, vip)) or false
      instances[#instances+1] = { sec="core", name="core", dev=dev, vip=vip, local_master=local_master }
    end
  end

  local peer_instances = {}
  if peer_host ~= "" then
    for _,it in ipairs(instances) do
      local remote_master = false
      if it.dev ~= "" and it.vip ~= "" then
        remote_master = vip_present_remote(peer_host, peer_user, peer_port, it.dev, it.vip)
      end
      peer_instances[#peer_instances+1] = {
        sec = it.sec, name = it.name, dev = it.dev, vip = it.vip,
        remote_master = remote_master
      }
    end
  end

  http.prepare_content("application/json")
  http.write_json({
    node = host, peer = peer_host,
    local_instances = instances, peer_instances = peer_instances
  })
end
