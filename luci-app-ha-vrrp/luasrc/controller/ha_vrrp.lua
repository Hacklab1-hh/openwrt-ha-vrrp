module("luci.controller.ha_vrrp", package.seeall)

function index()
  if not nixio.fs.access("/etc/config/ha_vrrp") then return end
  entry({"admin","services","ha_vrrp"}, firstchild(), _("HA VRRP"), 30).dependent=false
  entry({"admin","services","ha_vrrp","status"}, template("ha_vrrp/status"), _("Status")).leaf=true
  entry({"admin","services","ha_vrrp","wizard"}, template("ha_vrrp/wizard"), _("Wizard")).leaf=true

  entry({"admin","services","ha_vrrp","statusjson"}, call("statusjson")).leaf = true
  entry({"admin","services","ha_vrrp","listifaces"}, call("listifaces")).leaf = true
  entry({"admin","services","ha_vrrp","createinst"}, call("createinst")).leaf = true
  entry({"admin","services","ha_vrrp","discover_adv"}, call("discover_adv")).leaf = true
  entry({"admin","services","ha_vrrp","autodiscover"}, call("autodiscover")).leaf = true
  entry({"admin","services","ha_vrrp","setpeer"}, call("setpeer")).leaf = true

  entry({"admin","services","ha_vrrp","genkey"}, call("genkey")).leaf = true
  entry({"admin","services","ha_vrrp","importkey"}, call("importkey")).leaf = true

  entry({"admin","services","ha_vrrp","apply"}, call("apply")).leaf = true
  entry({"admin","services","ha_vrrp","sync"}, call("sync")).leaf = true
end

local function uci_cursor() return (require "luci.model.uci").cursor() end
local function http() return require "luci.http" end

local function readfile(p)
  local f = io.open(p, "r"); if not f then return "" end
  local d = f:read("*a") or ""; f:close(); return d
end

function statusjson()
  local uci = uci_cursor()
  local host = (readfile("/proc/sys/kernel/hostname"):gsub("%s+$",""))
  local peer = uci:get("ha_vrrp","core","peer_host") or ""

  local instances = {}
  uci:foreach("ha_vrrp", "instance", function(s)
    instances[#instances+1] = { id=s[".name"], name=(s.name or s[".name"]) }
  end)

  http().prepare_content("application/json")
  http().write_json({ node = host, peer = peer, instance_sections = instances })
end

function listifaces()
  local uci = uci_cursor()
  local ifs = {}
  uci:foreach("network","interface", function(s)
    local name = s[".name"]
    if name ~= "loopback" then
      local dhcp_enabled = false
      uci:foreach("dhcp","dhcp", function(d)
        if d.interface == name and (d.ignore ~= "1") then dhcp_enabled = true end
      end)
      ifs[#ifs+1] = {
        name=name, proto=s.proto or "", ipaddr=s.ipaddr or "", netmask=s.netmask or "",
        device = s.ifname or s.device or "", dhcp = dhcp_enabled
      }
    end
  end)
  http().prepare_content("application/json")
  http().write_json({ interfaces = ifs })
end

local function hash_to_vrid(s)
  local sum=0; for i=1,#(s or "") do sum=(sum + s:byte(i)) % 255 end; if sum==0 then sum=1 end; return sum
end

function createinst()
  local uci = uci_cursor(); local h = http()
  local iface = h.formvalue("iface") or ""
  local vip   = h.formvalue("vip") or ""
  local vrid  = h.formvalue("vrid") or ""
  local prio  = h.formvalue("priority") or "150"
  local state = h.formvalue("state") or "BACKUP"

  if iface=="" or vip=="" then h.status(400,"iface and vip required"); h.write("iface and vip required"); return end

  local src_ip = uci:get("network", iface, "ipaddr") or ""
  if src_ip=="" then
    local f = io.popen("ubus call network.interface."..iface.." status 2>/dev/null | jsonfilter -e '@.ipv4_address[0].address'")
    if f then src_ip = (f:read("*a") or ""):gsub("%s+$",""); f:close() end
  end
  if src_ip=="" then h.status(400, "cannot determine unicast_src_ip"); h.write("cannot determine unicast_src_ip"); return end

  if vrid=="" then vrid = tostring(hash_to_vrid(iface)) end

  local sec = "inst_"..iface; local i=0
  while uci:get("ha_vrrp", sec) do i=i+1; sec = "inst_"..iface.."_"..i end

  uci:set("ha_vrrp", sec, "instance")
  uci:set("ha_vrrp", sec, "name", iface:upper())
  uci:set("ha_vrrp", sec, "iface", iface)
  uci:set("ha_vrrp", sec, "vrid", vrid)
  uci:set("ha_vrrp", sec, "priority", prio)
  uci:set("ha_vrrp", sec, "state", state)
  uci:set("ha_vrrp", sec, "preempt", "1")
  uci:set("ha_vrrp", sec, "vip_cidr", vip)
  uci:set("ha_vrrp", sec, "unicast_src_ip", src_ip)
  uci:commit("ha_vrrp")

  os.execute("/usr/sbin/ha-vrrp-apply >/tmp/ha_vrrp_create.out 2>&1")
  os.execute("/etc/init.d/keepalived restart >/dev/null 2>&1")

  h.prepare_content("application/json")
  h.write_json({ ok=true, section=sec, vrid=vrid, src=src_ip })
end

function discover_adv()
  local h = http(); local uci = uci_cursor()
  local iface = h.formvalue("iface") or ""; local cidr = h.formvalue("cidr") or ""
  local subnet = cidr
  if subnet=="" and iface~="" then
    local ip = uci:get("network", iface, "ipaddr") or ""
    local mask = uci:get("network", iface, "netmask") or ""
    if ip~="" and mask~="" then subnet = ip.."/"..mask end
  end
  if subnet=="" then subnet = uci:get("ha_vrrp","core","discover_cidr") or "" end
  if subnet~="" then os.execute(string.format("uci -q set ha_vrrp.core.discover_cidr='%s' && uci -q commit ha_vrrp", subnet)) end

  local out = ""
  local f = io.popen("/usr/libexec/ha-vrrp/discover_peers.sh 2>/dev/null"); if f then out=f:read("*a") or ""; f:close() end
  local list = {}; for ip in out:gmatch("([%d%.]+)") do list[#list+1] = ip end
  h.prepare_content("application/json"); h.write_json({ peers=list, used_cidr=subnet })
end

function autodiscover()
  local h = http(); local uci = uci_cursor()
  local iface = h.formvalue("iface") or ""
  local src_ip = ""
  if iface~="" then
    src_ip = uci:get("network", iface, "ipaddr") or ""
    if src_ip=="" then
      local f = io.popen("ubus call network.interface."..iface.." status 2>/dev/null | jsonfilter -e '@.ipv4_address[0].address'")
      if f then src_ip=(f:read("*a") or ""):gsub("%s+$",""); f:close() end
    end
    local mask = uci:get("network", iface, "netmask") or ""
    if src_ip~="" and mask~="" then
      os.execute(string.format("uci -q set ha_vrrp.core.discover_cidr='%s/%s' && uci -q commit ha_vrrp", src_ip, mask))
    end
  end

  local out = ""; local f = io.popen("/usr/libexec/ha-vrrp/discover_peers.sh 2>/dev/null"); if f then out=f:read("*a") or ""; f:close() end
  local chosen = ""
  for ip in out:gmatch("([%d%.]+)") do if ip ~= src_ip then chosen = ip; break end end
  if chosen~="" then uci:set("ha_vrrp","core","peer_host",chosen); uci:commit("ha_vrrp") end
  h.prepare_content("application/json"); h.write_json({ ok=(chosen~=""), peer=chosen })
end

function setpeer()
  local h = http(); local uci = uci_cursor()
  local peer = h.formvalue("peer") or ""; local inst = h.formvalue("inst") or ""
  if peer=="" then h.status(400,"peer required"); h.write("peer required"); return end
  uci:set("ha_vrrp","core","peer_host",peer)
  if inst~="" then uci:delete("ha_vrrp", inst, "unicast_peer"); uci:add_list("ha_vrrp", inst, "unicast_peer", peer) end
  uci:commit("ha_vrrp")
  h.prepare_content("application/json"); h.write_json({ ok=true, peer=peer, inst=inst })
end

function genkey()
  local h = http()
  os.execute("mkdir -p /root/.ssh && chmod 700 /root/.ssh")
  local pub="/root/.ssh/id_ed25519.pub"; local prv="/root/.ssh/id_ed25519"
  local had = (os.execute("[ -s "..pub.." ] >/dev/null 2>&1")==0)
  if not had then
    if os.execute("command -v ssh-keygen >/dev/null 2>&1")==0 then
      os.execute("ssh-keygen -t ed25519 -N '' -f "..prv.." >/dev/null 2>&1")
    else
      prv="/root/.ssh/id_rsa"; pub="/root/.ssh/id_rsa.pub"
      os.execute("dropbearkey -t rsa -f "..prv.." >/dev/null 2>&1")
      os.execute("dropbearkey -y -f "..prv.." | grep -E '^ssh-(rsa|ed25519) ' > "..pub)
    end
  end
  local f=io.open(pub,"r"); local pk=f and f:read('*a') or ""; if f then f:close() end
  h.prepare_content("application/json"); h.write_json({ ok=(pk~=""), created=(not had), pubkey=pk })
end

function importkey()
  local h = http(); local pub = h.formvalue("pub") or ""
  if pub=="" then h.status(400,"pub required"); h.write("pub required"); return end
  os.execute("mkdir -p /root/.ssh && chmod 700 /root/.ssh && touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys")
  if not pub:match("\n$") then pub = pub.."\n" end
  local ak="/root/.ssh/authorized_keys"; local cur=readfile(ak)
  if not cur:find(pub, 1, true) then local w=io.open(ak,"a"); if w then w:write(pub); w:close() end end
  h.prepare_content("application/json"); h.write_json({ ok=true, added=true })
end

function apply()
  os.execute("/usr/sbin/ha-vrrp-apply >/tmp/ha_vrrp_apply.out 2>&1 && /etc/init.d/keepalived restart >/dev/null 2>&1")
  http().prepare_content("application/json"); http().write_json({ ok=true })
end

function sync()
  os.execute("/usr/sbin/ha-vrrp-sync push >/tmp/ha_vrrp_sync.out 2>&1")
  http().prepare_content("application/json"); http().write_json({ ok=true })
end
