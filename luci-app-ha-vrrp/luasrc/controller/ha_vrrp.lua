module("luci.controller.ha_vrrp", package.seeall)

function index()
  if not nixio.fs.access("/etc/config/ha_vrrp") then return end

  local root = {"admin","services","ha_vrrp"}
  local e = entry(root, alias("admin","services","ha_vrrp","overview"), _("HA VRRP"), 60)
  e.dependent = true

  entry({"admin","services","ha_vrrp","overview"},  cbi("ha_vrrp/overview"),  _("Overview"),  10).leaf = true
  entry({"admin","services","ha_vrrp","status"},    template("ha_vrrp/status"),_("Status"),    15).leaf = true
  entry({"admin","services","ha_vrrp","instances"}, cbi("ha_vrrp/instances"), _("Instances"), 20).leaf = true
  entry({"admin","services","ha_vrrp","sync"},      cbi("ha_vrrp/sync"),      _("Sync & Keys"),30).leaf = true
  entry({"admin","services","ha_vrrp","settings"},  cbi("ha_vrrp/settings"),  _("Settings"),  40).leaf = true
  entry({"admin","services","ha_vrrp","wizard"},    cbi("ha_vrrp/wizard"),    _("Setup Wizard"),50).leaf = true

  -- JSON APIs
  entry({"admin","services","ha_vrrp","api","status"},     call("api_status")).leaf = true
  entry({"admin","services","ha_vrrp","api","statusjson"}, call("statusjson")).leaf = true
  entry({"admin","services","ha_vrrp","api","apply"},      call("apply_cfg")).leaf = true
  entry({"admin","services","ha_vrrp","api","ifaces"},     call("list_ifaces")).leaf = true
  entry({"admin","services","ha_vrrp","api","peers"},      call("discover_peers")).leaf = true
  entry({"admin","services","ha_vrrp","api","keysync"},    call("ssh_keysync")).leaf = true
  entry({"admin","services","ha_vrrp","api","syncpush"},   call("sync_push")).leaf = true
end

local function read_cmd(cmd)
  local p = io.popen(cmd .. " 2>/dev/null")
  if not p then return "" end
  local out = p:read("*a") or ""
  p:close()
  return out
end

function statusjson()
  local http = require "luci.http"
  local uci  = require "luci.model.uci".cursor()
  local json = require "luci.jsonc"

  local st = {
    now = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    host = read_cmd("uci get system.@system[0].hostname || uname -n"):gsub("%s+$",""),
    role = read_cmd("pgrep -f 'keepalived.*MASTER' >/dev/null && echo MASTER || echo BACKUP"):gsub("%s+$",""),
    ka   = read_cmd("keepalived -v 2>/dev/null | head -n1"):gsub("%s+$",""),
    vrrp = read_cmd("ip -o addr show | grep -E 'vrrp|VRRP' | wc -l"):gsub("%s+$",""),
    peer = uci:get("ha_vrrp","core","peer_host") or "",
    cluster = uci:get("ha_vrrp","core","cluster_name") or "-",
  }

  if st.peer ~= "" then
    st.peer_ping = (os.execute("ping -c1 -w1 " .. st.peer .. " >/dev/null 2>&1") == 0)
  end

  http.prepare_content("application/json")
  http.write(json.stringify(st))
end

function apply_cfg()
  local http = require "luci.http"
  read_cmd("[ -x /usr/lib/ha-vrrp/scripts/migrate_0.5.16_002_to_006.sh ] && /usr/lib/ha-vrrp/scripts/migrate_0.5.16_002_to_006.sh || true")
  read_cmd("ha-vrrp-apply >/dev/null 2>&1 || true; /etc/init.d/keepalived restart >/dev/null 2>&1 || true")
  http.prepare_content("application/json")
  http.write('{"ok":true}')
end

function list_ifaces()
  local http = require "luci.http"
  local json = require "luci.jsonc"
  local out = read_cmd("ip -o -4 link show | awk -F': ' '{print $2}' | grep -v '^lo$'")
  local ifs = {}
  for ifn in out:gmatch("[^%s]+") do ifs[#ifs+1]=ifn end
  http.prepare_content("application/json")
  http.write(json.stringify({ ifaces = ifs }))
end

function discover_peers()
  local http = require "luci.http"
  local json = require "luci.jsonc"
  local out = read_cmd("arp -an | awk '{print $2}' | tr -d '()'")
  local peers = {}
  for ip in out:gmatch("[^\r\n]+") do peers[#peers+1]=ip end
  http.prepare_content("application/json")
  http.write(json.stringify({ peers = peers }))
end

function ssh_keysync()
  local http = require "luci.http"
  read_cmd("/usr/lib/ha-vrrp/scripts/ssh_keys_sync.sh >/dev/null 2>&1 || true")
  http.prepare_content("application/json")
  http.write('{"ok":true}')
end

function sync_push()
  local http = require "luci.http"
  read_cmd("/usr/lib/ha-vrrp/scripts/sync_push.sh >/dev/null 2>&1 || true")
  http.prepare_content("application/json")
  http.write('{"ok":true}')
end
