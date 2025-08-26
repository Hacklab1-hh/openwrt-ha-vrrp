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
  entry({"admin","services","ha_vrrp","listifaces"}, call("listifaces"), nil).leaf = true
  entry({"admin","services","ha_vrrp","createinst"}, call("createinst"), nil).leaf = true
  entry({"admin","services","ha_vrrp","discover_adv"}, call("discover_adv"), nil).leaf = true
  entry({"admin","services","ha_vrrp","autodiscover"}, call("autodiscover"), nil).leaf = true
  entry({"admin","services","ha_vrrp","setpeer"}, call("setpeer"), nil).leaf = true
  entry({"admin","services","ha_vrrp","genkey"}, call("genkey"), nil).leaf = true
  entry({"admin","services","ha_vrrp","importkey"}, call("importkey"), nil).leaf = true
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
    instance_sections = (function()
      local t = {}
      uci:foreach("ha_vrrp", "instance", function(s)
        t[#t+1] = { id = s[".name"], name = (s.name or s[".name"]) }
      end)
      return t
    end)(),
    local_instances = instances, peer_instances = peer_instances
  })
end




function listifaces()
  local http = require "luci.http"
  local uci = require "luci.model.uci".cursor()

  local ifs = {}
  -- Collect logical interfaces from /etc/config/network
  uci:foreach("network", "interface", function(s)
    local name = s[".name"]
    -- Skip loopback and wan if desired? We'll include all except 'loopback'
    if name ~= "loopback" then
      local proto = s.proto or ""
      local ipaddr = s.ipaddr or ""
      local netmask = s.netmask or ""
      local device = s.ifname or s.device or ""
      -- DHCP server status from /etc/config/dhcp (section 'dhcp' with option interface = name, and ignore != 1)
      local dhcp_enabled = false
      uci:foreach("dhcp", "dhcp", function(d)
        if d.interface == name then
          if (d.ignore ~= "1") then dhcp_enabled = true end
        end
      end)
      ifs[#ifs+1] = {
        name = name, proto = proto, ipaddr = ipaddr, netmask = netmask, device = device, dhcp = dhcp_enabled
      }
    end
  end)

  http.prepare_content("application/json")
  http.write_json({ interfaces = ifs })
end

local function hash_to_vrid(s)
  -- Simple deterministic hash 1..254
  local sum = 0
  for i = 1, #s do sum = (sum + s:byte(i)) % 255 end
  if sum == 0 then sum = 1 end
  return sum
end

function createinst()
  local http = require "luci.http"
  local uci = require "luci.model.uci".cursor()
  local iface = http.formvalue("iface") or ""
  local vip = http.formvalue("vip") or ""
  local vrid = http.formvalue("vrid") or ""
  local prio = http.formvalue("priority") or ""
  local state = http.formvalue("state") or ""

  if iface == "" or vip == "" then
    http.status(400, "iface and vip required")
    http.write("iface and vip required")
    return
  end

  -- derive unicast_src_ip from network.iface.ipaddr
  local src_ip = uci:get("network", iface, "ipaddr") or ""
  -- If ipaddr absent (e.g., DHCP client), try to read runtime ip (best-effort)
  if src_ip == "" then
    local f = io.popen("ubus call network.interface."..iface.." status 2>/dev/null | jsonfilter -e '@.ipv4_address[0].address'")
    if f then src_ip = (f:read("*a") or ""):gsub("%s+$",""); f:close() end
  end

  if src_ip == "" then
    http.status(400, "cannot determine unicast_src_ip for iface "..iface)
    http.write("cannot determine unicast_src_ip for iface "..iface)
    return
  end

  if vrid == "" then vrid = tostring(hash_to_vrid(iface)) end
  if prio == "" then prio = "150" end
  if state == "" then state = "BACKUP" end

  -- Create new instance section id
  local sec = "inst_" .. iface
  -- Ensure uniqueness
  local idx = 0
  while uci:get("ha_vrrp", sec) do
    idx = idx + 1
    sec = "inst_" .. iface .. "_" .. idx
  end

  uci:set("ha_vrrp", sec, "instance")
  uci:set("ha_vrrp", sec, "name", iface:upper())
  uci:set("ha_vrrp", sec, "iface", iface)
  uci:set("ha_vrrp", sec, "vrid", vrid)
  uci:set("ha_vrrp", sec, "priority", prio)
  uci:set("ha_vrrp", sec, "state", state)
  uci:set("ha_vrrp", sec, "preempt", "1")
  uci:set("ha_vrrp", sec, "vip_cidr", vip)
  uci:set("ha_vrrp", sec, "unicast_src_ip", src_ip)
  -- Note: unicast_peer left empty; user can fill via LuCI Core tab or add peers later

  uci:commit("ha_vrrp")

  -- Apply keepalived config
  os.execute("/usr/sbin/ha-vrrp-apply >/tmp/ha_vrrp_create.out 2>&1")
  os.execute("/etc/init.d/keepalived restart >/dev/null 2>&1")

  http.prepare_content("application/json")
  http.write_json({ ok = true, section = sec, vrid = vrid, src = src_ip })
end


-- Advanced discovery: allow iface or cidr override
function discover_adv()
  local http = require "luci.http"
  local uci = require "luci.model.uci".cursor()
  local iface = http.formvalue("iface") or ""
  local cidr = http.formvalue("cidr") or ""

  local subnet = cidr
  if subnet == "" and iface ~= "" then
    local ip = uci:get("network", iface, "ipaddr") or ""
    local mask = uci:get("network", iface, "netmask") or ""
    if ip ~= "" and mask ~= "" then
      subnet = ip .. "/" .. mask
    end
  end

  -- If still empty, fall back to core.discover_cidr
  if subnet == "" then
    subnet = uci:get("ha_vrrp", "core", "discover_cidr") or ""
  end

  -- Temporarily override discover_cidr for the script call
  local cmd = "/usr/libexec/ha-vrrp/discover_peers.sh"
  if subnet ~= "" then
    -- We can't pass args, so we set UCI temporarily
    os.execute(string.format("uci -q set ha_vrrp.core.discover_cidr='%s'", subnet))
    os.execute("uci -q commit ha_vrrp")
  end

  local f = io.popen(cmd .. " 2>/dev/null")
  local out = f and (f:read("*a") or "") or ""
  if f then f:close() end

  local list = {}
  for ip in out:gmatch("([%d%.]+)") do list[#list+1] = ip end
  http.prepare_content("application/json")
  http.write_json({ peers = list, used_cidr = subnet })
end

-- Auto choose first discovered peer != local src ip
function autodiscover()
  local http = require "luci.http"
  local uci = require "luci.model.uci".cursor()
  local iface = http.formvalue("iface") or ""

  local src_ip = ""
  if iface ~= "" then
    src_ip = uci:get("network", iface, "ipaddr") or ""
    if src_ip == "" then
      local f = io.popen("ubus call network.interface."..iface.." status 2>/dev/null | jsonfilter -e '@.ipv4_address[0].address'")
      if f then src_ip = (f:read("*a") or ""):gsub("%s+$",""); f:close() end
    end
    -- derive cidr from network config if possible
    local mask = uci:get("network", iface, "netmask") or ""
    if src_ip ~= "" and mask ~= "" then
      os.execute(string.format("uci -q set ha_vrrp.core.discover_cidr='%s/%s'", src_ip, mask))
      os.execute("uci -q commit ha_vrrp")
    end
  end

  local f = io.popen("/usr/libexec/ha-vrrp/discover_peers.sh 2>/dev/null")
  local out = f and (f:read(\"*a\") or \"\") or \"\"
  if f then f:close() end

  local chosen = ""
  for ip in out:gmatch(\"([%d%.]+)\") do
    if ip ~= src_ip then chosen = ip; break end
  end
  if chosen ~= \"\" then
    uci:set(\"ha_vrrp\",\"core\",\"peer_host\",chosen)
    uci:commit(\"ha_vrrp\")
  end

  http.prepare_content(\"application/json\")
  http.write_json({ ok = (chosen ~= \"\"), peer = chosen })
end

-- Set peer for core and optionally add as unicast_peer for a given instance
function setpeer()
  local http = require \"luci.http\"
  local uci = require \"luci.model.uci\".cursor()
  local peer = http.formvalue(\"peer\") or \"\"
  local inst = http.formvalue(\"inst\") or \"\"  -- optional instance section to add unicast_peer
  if peer == \"\" then
    http.status(400, \"peer required\"); http.write(\"peer required\"); return
  end
  uci:set(\"ha_vrrp\",\"core\",\"peer_host\",peer)
  if inst ~= \"\" then
    uci:delete(\"ha_vrrp\", inst, \"unicast_peer\") -- reset and add fresh
    uci:add_list(\"ha_vrrp\", inst, \"unicast_peer\", peer)
  end
  uci:commit(\"ha_vrrp\")
  http.prepare_content(\"application/json\")
  http.write_json({ ok = true, peer = peer, inst = inst })
end



function genkey()
  local http = require "luci.http"
  local home = "/root"
  local sshdir = home .. "/.ssh"
  os.execute("mkdir -p "..sshdir.." && chmod 700 "..sshdir)

  local pub, prv = sshdir.."/id_ed25519.pub", sshdir.."/id_ed25519"
  local had_key = (os.execute("[ -s "..pub.." ] >/dev/null 2>&1") == 0)

  if not had_key then
    local ok = os.execute("command -v ssh-keygen >/dev/null 2>&1")
    if ok == 0 then
      os.execute("ssh-keygen -t ed25519 -N '' -f "..prv.." >/dev/null 2>&1")
    else
      prv = sshdir.."/id_rsa"
      pub = sshdir.."/id_rsa.pub"
      os.execute("dropbearkey -t rsa -f "..prv.." >/dev/null 2>&1")
      os.execute("dropbearkey -y -f "..prv.." | awk '/^ssh-/{print $0}' > "..pub)
    end
  end

  local f = io.open(pub, "r")
  local pubkey = f and f:read("*a") or ""
  if f then f:close() end

  http.prepare_content("application/json")
  http.write_json({ ok = (pubkey ~= ""), created = (not had_key), pubkey = pubkey })
end

function importkey()
  local http = require "luci.http"
  local pub = http.formvalue("pub") or ""
  if pub == "" then http.status(400, "pub required"); http.write("pub required"); return end
  local sshdir = "/root/.ssh"
  os.execute("mkdir -p "..sshdir.." && chmod 700 "..sshdir)
  if not pub:match("\n$") then pub = pub .. "\n" end
  local ak = sshdir.."/authorized_keys"
  os.execute("touch "..ak.." && chmod 600 "..ak)
  local exists = false
  local f = io.open(ak, "r")
  if f then
    local all = f:read("*a") or ""
    f:close()
    if all:find(pub, 1, true) then exists = true end
  end
  if not exists then
    local w = io.open(ak, "a")
    if w then w:write(pub); w:close() end
  end
  http.prepare_content("application/json")
  http.write_json({ ok = true, added = (not exists) })
end
