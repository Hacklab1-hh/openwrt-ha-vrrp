-- PATH: luci-app-ha-vrrp/luasrc/controller/ha_vrrp.lua
module("luci.controller.ha_vrrp", package.seeall)

function index()
  if not nixio.fs.access("/etc/config/ha_vrrp") then return end

  local e = entry({"admin","services","ha_vrrp"}, alias("admin","services","ha_vrrp","overview"), _("HA VRRP"), 60)
  e.dependent = true

  entry({"admin","services","ha_vrrp","overview"},  cbi("ha_vrrp/overview"),  _("Overview"),       10).leaf = true
  entry({"admin","services","ha_vrrp","instances"}, cbi("ha_vrrp/instances"), _("Instances"),      20).leaf = true
  entry({"admin","services","ha_vrrp","sync"},      cbi("ha_vrrp/sync"),      _("Sync und Keys"),  30).leaf = true
  entry({"admin","services","ha_vrrp","settings"},  cbi("ha_vrrp/settings"),  _("Settings"),       40).leaf = true

  -- API
  entry({"admin","services","ha_vrrp","api","status"}, call("api_status")).leaf = true

  -- Frontend-Endpoints, die status.htm aufruft:
  entry({"admin","services","ha_vrrp","statusjson"}, call("statusjson")).leaf = true
  entry({"admin","services","ha_vrrp","apply"},      call("apply_cfg")).leaf = true
  entry({"admin","services","ha_vrrp","interfaces"}, call("list_ifaces")).leaf = true
  entry({"admin","services","ha_vrrp","discover"},   call("discover_peers")).leaf = true
  entry({"admin","services","ha_vrrp","keysync"},    call("keysync")).leaf = true
  entry({"admin","services","ha_vrrp","syncpush"},   call("syncpush")).leaf = true
  entry({"admin","services","ha_vrrp","createinst"}, call("createinst")).leaf = true
end

-- Bestehendes Mini-Status-API
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

-- Hilfsfunktionen
local function read_cmd(cmd)
  local f = io.popen(cmd .. " 2>/dev/null")
  if not f then return "" end
  local out = f:read("*a") or ""
  f:close()
  return out
end

local function get_instances(uci)
  -- sammelt UCI-Instanzen (Sektionen vom Typ "instance" oder "inst_*")
  local inst = {}
  uci:foreach("ha_vrrp","instance", function(s)
    s.__section = s[".name"]; inst[#inst+1] = s
  end)
  -- Fallback: generische Sektionen "inst_*"
  uci:foreach("ha_vrrp", nil, function(s)
    local n = s[".name"] or ""
    if n:match("^inst_") then s.__section=n; inst[#inst+1]=s end
  end)
  return inst
end

-- JSON für status.htm
function statusjson()
  local http = require "luci.http"
  local sys  = require "luci.sys"
  local uci  = require "luci.model.uci".cursor()

  local node = read_cmd("uci -q get system.@system[0].hostname"):gsub("%s+$","")
  local peer = uci:get("ha_vrrp","core","peer_host") or ""
  local ping_ok = false
  if peer ~= "" then ping_ok = (sys.call("ping -c1 -W1 "..peer.." >/dev/null 2>&1") == 0) end

  local local_instances = {}
  for _,s in ipairs(get_instances(uci)) do
    local name = s.name or s.__section or "-"
    local dev  = s.iface or s.interface or "wan"
    local vip  = s.vip_cidr or s.vip or ""
    local_instances[#local_instances+1] = {
      name = name, dev = dev, vip = vip, local_master = false
    }
  end

  -- Peer-Infos (optional): hier Dummy/Placeholder; echte Abfrage ggf. über RPCD/ubus/ssh json
  local peer_instances = {}
  for _,li in ipairs(local_instances) do
    peer_instances[#peer_instances+1] = { name = li.name, remote_master = false }
  end

  http.prepare_content("application/json")
  http.write_json({
    ok=true, node=node, peer=peer, ping=ping_ok,
    local_instances=local_instances, peer_instances=peer_instances
  })
end

-- Apply & Keepalived Neustart
function apply_cfg()
  local http = require "luci.http"
  read_cmd("ha-vrrp-apply >/dev/null 2>&1 || true; /etc/init.d/keepalived restart >/dev/null 2>&1 || true")
  http.prepare_content("application/json")
  http.write_json({ ok=true })
end

-- Netz-Interfaces (für Wizard/Statusseite)
function list_ifaces()
  local http = require "luci.http"
  local out = read_cmd("ip -o -4 link show | awk -F': ' '{print $2}' | grep -v '^lo$'")
  local ifs = {}
  for ifn in out:gmatch("[^\r\n]+") do ifs[#ifs+1]=ifn end
  http.prepare_content("application/json")
  http.write_json({ ok=true, interfaces=ifs })
end

-- Auto-Discovery
function discover_peers()
  local http = require "luci.http"
  read_cmd("/usr/libexec/ha-vrrp/discover_peers.sh >/tmp/ha-vrrp-discover.log 2>&1 || true")
  http.prepare_content("application/json")
  http.write_json({ ok=true })
end

-- SSH-Key-Sync
function keysync()
  local http = require "luci.http"
  read_cmd("ha-vrrp-sync keysync >/tmp/ha-vrrp-keysync.log 2>&1 || true")
  http.prepare_content("application/json")
  http.write_json({ ok=true })
end

-- Aktiven Sync schieben
function syncpush()
  local http = require "luci.http"
  read_cmd("ha-vrrp-sync push >/tmp/ha-vrrp-syncpush.log 2>&1 || true")
  http.prepare_content("application/json")
  http.write_json({ ok=true })
end

-- Instanz anlegen (Wizard-Button)
function createinst()
  local http = require "luci.http"
  local uci  = require "luci.model.uci".cursor()
  local iface = http.formvalue("iface") or ""
  local vip   = http.formvalue("vip") or ""
  local vrid  = http.formvalue("vrid") or ""

  if iface == "" or vip == "" then
    http.status(400, "Bad Request"); http.write("missing iface/vip"); return
  end

  -- section name
  local sec = "inst_" .. (vrid ~= "" and vrid or tostring(math.random(2,254)))
  uci:set("ha_vrrp", sec, "instance")
  uci:set("ha_vrrp", sec, "name", sec)
  uci:set("ha_vrrp", sec, "iface", iface)
  uci:set("ha_vrrp", sec, "vip_cidr", vip)
  if vrid ~= "" then uci:set("ha_vrrp", sec, "vrid", tonumber(vrid)) end
  uci:set("ha_vrrp", sec, "state", "BACKUP")
  uci:set("ha_vrrp", sec, "priority", 150)
  -- WICHTIG: unicast_src_ip MUSS gesetzt werden; wir versuchen eine Auto-IP vom iface:
  local auto_ip = read_cmd("ip -o -4 addr show dev "..iface.." | awk '{print $4}' | cut -d/ -f1 | head -n1"):gsub("%s+$","")
  if auto_ip ~= "" then uci:set("ha_vrrp", sec, "unicast_src_ip", auto_ip) end
  uci:commit("ha_vrrp")

  http.prepare_content("application/json")
  http.write_json({ ok=true, section=sec, vrid=uci:get("ha_vrrp",sec,"vrid") or "-" })
end

