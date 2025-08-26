import os, tarfile, shutil, re, textwrap, json, datetime, io

BASE_TGZ = "/root/vrrp-repo/openwrt-ha-vrrp-0.5.16-002.tar.gz"
assert os.path.exists(BASE_TGZ), "Base 0.5.16-002.tar.gz not found"

variant_prev = "0.5.16-002"
variant_new  = "0.5.16-004"

work = "/mnt/data/_0516_004_edit"
if os.path.isdir(work): shutil.rmtree(work)
os.makedirs(work, exist_ok=True)

# 1) Unpack base
with tarfile.open(BASE_TGZ, "r:gz") as tar:
    tar.extractall(work)

# detect repo root
roots = [os.path.join(work,d) for d in os.listdir(work) if os.path.isdir(os.path.join(work,d))]
assert roots, "No repo root after extract"
root = roots[0]

def r(path): return os.path.join(root, path)

def read(path, default=""):
    p=r(path)
    return open(p,"r",encoding="utf-8",errors="ignore").read() if os.path.exists(p) else default

def write(path, content, mode=0o644):
    p=r(path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p,"w",encoding="utf-8") as f: f.write(content)
    os.chmod(p, mode)

def append(path, content):
    p=r(path); os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p,"a",encoding="utf-8") as f: f.write(content)

# 2) Config defaults: add ssh_backend, peer_netmask_cidr, cluster_version
uci_cfg = "ha-vrrp/files/etc/config/ha_vrrp"
txt = read(uci_cfg)
if txt:
    changed=False
    if "option ssh_backend" not in txt:
        txt = re.sub(r"(config core 'core'.*?\n)", r"\1\toption ssh_backend 'auto'\n", txt, flags=re.S); changed=True
    if "option peer_netmask_cidr" not in txt:
        txt = re.sub(r"(config core 'core'.*?\n)", r"\1\toption peer_netmask_cidr '24'\n", txt, flags=re.S); changed=True
    if "option cluster_version" not in txt:
        txt = re.sub(r"(config core 'core'.*?\n)", r"\1\toption cluster_version '"+variant_new+"'\n", txt, flags=re.S); changed=True
    if changed:
        write(uci_cfg, txt)

# 3) Views fixes/enhancements
# 3a) Overview template: fix 'm' nil by using self.map.uci; show version
overview_htm_path="luci-app-ha-vrrp/luasrc/view/ha_vrrp/overview.htm"
overview_htm = textwrap.dedent(r'''
<%+header%>
<h2><%:HA VRRP Overview%></h2>
<% local data = self and self.map and self.map.uci or {} %>
<ul>
  <li><b><%:Addon-Version%>:</b> <%=data.version or "-"%></li>
  <li><b><%:Cluster%>:</b> <%=data.cluster or "-"%></li>
  <li><b><%:Peer%>:</b> <%=data.peer or "-"%> (<%:Status%>: <%=data.ping_ok or "-"%>)</li>
  <li><b><%:SSH-Backend%>:</b> <%=data.ssh_backend or "auto"%></li>
  <li><b><%:Key-Typ%>:</b> <%=data.key_type or "auto"%></li>
  <li><b><%:Sync-Methode%>:</b> <%=data.sync_method or "auto"%></li>
  <li><b><%:Priority%>:</b> <%=data.priority or "-"%></li>
</ul>
<p><a href="<%=url('admin/services/ha_vrrp/sync')%>"><%:Zu "Sync und Keys"%></a></p>
<%+footer%>
''').strip()+"\n"
write(overview_htm_path, overview_htm)

# Inject 'version' and ssh_backend into overview.lua map data; ensure file exists or create minimal
overview_cbi_path="luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/overview.lua"
if not os.path.exists(r(overview_cbi_path)):
    overview_lua = textwrap.dedent(r'''
local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()

local m = Map("ha_vrrp", translate("HA VRRP"))

local s = m:section(SimpleSection, translate("Cluster-Status"))
local peer = uci:get("ha_vrrp","core","peer_host") or ""
local cluster = uci:get("ha_vrrp","core","cluster_name") or "-"
local key_type = uci:get("ha_vrrp","core","key_type") or "auto"
local sync_method = uci:get("ha_vrrp","core","sync_method") or "auto"
local ssh_backend = uci:get("ha_vrrp","core","ssh_backend") or "auto"
local priority = uci:get("ha_vrrp","core","priority") or "150"
local version = uci:get("ha_vrrp","core","cluster_version") or "-"
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
  ssh_backend = ssh_backend,
  priority = priority,
  version = version,
  ping_ok = ping_ok and "reachable" or "unreachable"
}

-- Minimal discover section to keep compatibility; action handled server-side scripts
local psec = m:section(TypedSection, "discover", translate("Peer Discovery"))
psec.anonymous = true
local ifc = psec:option(ListValue, "iface", translate("Interface"))
ifc:value("HEARTBEAT", "HEARTBEAT")
ifc:value("ADMINLAN", "ADMINLAN")
ifc:value("LAN", "LAN")
ifc.default = "HEARTBEAT"
local run = psec:option(Button, "_run_discover", translate("Discover"))
run.inputstyle="apply"
function run.write(self, section, value)
  local iface = ifc:formvalue(section) or "HEARTBEAT"
  local rc = sys.call(string.format("/usr/libexec/ha-vrrp/discover.sh %q > /tmp/ha_vrrp_discover.json 2>&1", iface))
  luci.http.redirect(luci.dispatcher.build_url("admin/services/ha_vrrp/overview"))
end

return m
''').strip()+"\n"
    write(overview_cbi_path, overview_lua)
else:
    # ensure fields present
    t = read(overview_cbi_path)
    if "ssh_backend" not in t or "cluster_version" not in t:
        # regenerate safely (simpler)
        write(overview_cbi_path, re.sub(r'.*', '', t))
        # write fresh (above)
        write(overview_cbi_path, overview_lua)

# 3b) Settings: add ssh_backend and peer_netmask_cidr + help texts
settings_path="luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/settings.lua"
t=read(settings_path)
if not t:
    t = textwrap.dedent(r'''
local m = Map("ha_vrrp", translate("Settings"))
local s = m:section(NamedSection, "core", "core", translate("Core Settings"))
local o
o = s:option(Value, "cluster_name", translate("Cluster Name"))
o = s:option(Value, "peer_host", translate("Peer Host (IP/Name)"))

o = s:option(Value, "peer_netmask_cidr", translate("Peer-Netzmaske (CIDR)"))
o.datatype="ufloat"; o.placeholder="24"
o.description = translate("CIDR-Präfix, z.B. 24 für /24")

o = s:option(ListValue, "ssh_backend", translate("SSH-Backend"))
o:value("auto","auto"); o:value("openssh","OpenSSH"); o:value("dropbear","Dropbear")
o.description = translate("Auto erkennt OpenSSH/Dropbear und nutzt bevorzugt OpenSSH wenn verfügbar.")

o = s:option(ListValue, "fw_backend", translate("Firewall Backend"))
o:value("auto","auto"); o:value("iptables","iptables"); o:value("nft","nft")
o = s:option(ListValue, "ka_backend", translate("Keepalived Backend"))
o:value("auto","auto"); o:value("ka_2x","ka_2x"); o:value("ka_2_2plus","ka_2_2plus")
o = s:option(ListValue, "dhcp_backend", translate("DHCP/DNS Backend"))
o:value("auto","auto"); o:value("dnsmasq_legacy","dnsmasq_legacy"); o:value("dnsmasq_fw4","dnsmasq_fw4")
o = s:option(ListValue, "net_backend", translate("Netzwerk Backend"))
o:value("auto","auto"); o:value("swconfig","swconfig"); o:value("dsa","dsa")
o = s:option(ListValue, "key_type", translate("Bevorzugter Schlüsseltyp"))
o:value("auto","auto (ed25519 bevorzugt)"); o:value("ed25519","ed25519"); o:value("rsa","rsa")
o = s:option(ListValue, "sync_method", translate("Sync-Methode"))
o:value("auto","auto"); o:value("scp","scp"); o:value("rsync","rsync")
o = s:option(Value, "priority", translate("VRRP Priority (0-255)"))
o.datatype="range(0,255)"; o.placeholder="150"
return m
''').strip()+"\n"
    write(settings_path, t)
else:
    # add ssh_backend and peer_netmask_cidr if missing
    add = ""
    if "ssh_backend" not in t:
        add += "\nlocal o = s:option(ListValue, 'ssh_backend', translate('SSH-Backend'))\no:value('auto','auto'); o:value('openssh','OpenSSH'); o:value('dropbear','Dropbear')\no.description = translate('Auto erkennt OpenSSH/Dropbear und nutzt bevorzugt OpenSSH wenn verfügbar.')\n"
    if "peer_netmask_cidr" not in t:
        add += "\nlocal o = s:option(Value, 'peer_netmask_cidr', translate('Peer-Netzmaske (CIDR)'))\no.datatype='ufloat'; o.placeholder='24'\no.description = translate('CIDR-Präfix, z.B. 24 für /24')\n"
    if add:
        t += "\n-- v0.5.16-004 additions\n" + add
        write(settings_path, t)

# 3c) Sync CBI: allow uploading priv key, peer pub key; small description texts
sync_cbi="luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/sync.lua"
sync_t=read(sync_cbi)
if not sync_t:
    sync_t = textwrap.dedent(r'''
local sys  = require "luci.sys"
local util = require "luci.util"
local http = require "luci.http"

local m = Map("ha_vrrp", translate("Sync und Keys"))

local s = m:section(SimpleSection, translate("SSH/Sync Aktionen"))
s.template = "ha_vrrp/sync"

local t = m:section(NamedSection, "core", "core", translate("Sync-Settings"))
local o

o = t:option(Value, "peer_host", translate("Peer Host (IP/Hostname)"))
o.placeholder = "192.168.254.2"

o = t:option(Value, "peer_netmask_cidr", translate("Peer-Netzmaske (CIDR)"))

o = t:option(ListValue, "ssh_backend", translate("SSH-Backend"))
o:value("auto", "auto"); o:value("openssh","OpenSSH"); o:value("dropbear","Dropbear")

o = t:option(ListValue, "key_type", translate("Bevorzugter Schlüsseltyp"))
o:value("auto", "auto (ed25519 bevorzugt)")
o:value("ed25519", "ed25519")
o:value("rsa", "rsa")

o = t:option(ListValue, "sync_method", translate("Sync-Methode"))
o:value("auto", "auto")
o:value("scp", "scp")
o:value("rsync", "rsync")

local function action_btn(cmd, label)
  local btn = t:option(Button, "_"..cmd, label)
  btn.inputstyle = "apply"
  function btn.write(self, section, value)
    local rc = sys.call("/usr/libexec/ha-vrrp/sync/"..cmd..".sh >/tmp/ha_vrrp_"..cmd.." 2>&1")
    http.redirect(luci.dispatcher.build_url("admin/services/ha_vrrp/sync"))
  end
  return btn
end

action_btn("generate_keys", translate("Schlüssel erzeugen"))
action_btn("setup_ssh_config", translate("SSH-Config einrichten"))
action_btn("push_keys", translate("Keys zum Peer pushen"))

local function action_btn2(cmd, label)
  local btn = t:option(Button, "_"..cmd, label)
  btn.inputstyle = "apply"
  function btn.write(self, section, value)
    local rc = sys.call("/usr/libexec/ha-vrrp/rpc/"..cmd..".wrapper >/tmp/ha_vrrp_rpc_"..cmd.." 2>&1")
    http.redirect(luci.dispatcher.build_url("admin/services/ha_vrrp/sync"))
  end
  return btn
end
action_btn2("ssh-copy-key", translate("ssh-copy-key → Peer"))
action_btn2("rpc-exec", translate("RPC-Test (echo)"))

-- Upload areas
local up_local_pub = t:option(FileUpload, "upload_local_pub", translate("Lokalen öffentlichen Schlüssel (.pub) hochladen"))
local up_local_priv = t:option(FileUpload, "upload_local_priv", translate("Lokalen privaten Schlüssel hochladen"))
local up_peer_pub = t:option(FileUpload, "upload_peer_pub", translate("Peer-öffentlichen Schlüssel (.pub) hochladen (trust)"))
up_local_pub.rmempty = true; up_local_priv.rmempty = true; up_peer_pub.rmempty = true

function m.handle(self, state, data)
  if state == FORM_VALID and data then
    if data.upload_local_pub then
      sys.call("mkdir -p /etc/ha-vrrp/keys && cp -f "..util.shellquote(data.upload_local_pub).." /etc/ha-vrrp/keys/local_identity.pub")
    end
    if data.upload_local_priv then
      sys.call("mkdir -p /etc/ha-vrrp/keys && cp -f "..util.shellquote(data.upload_local_priv).." /etc/ha-vrrp/keys/local_identity")
      sys.call("chmod 600 /etc/ha-vrrp/keys/local_identity")
    end
    if data.upload_peer_pub then
      sys.call("mkdir -p /etc/ha-vrrp/keys && cp -f "..util.shellquote(data.upload_peer_pub).." /etc/ha-vrrp/keys/peer_authorized.pub")
    end
  end
  return Map.handle(self, state, data)
end

return m
''').strip()+"\n"
    write(sync_cbi, sync_t)
else:
    # append upload options if missing
    if "upload_local_priv" not in sync_t or "upload_peer_pub" not in sync_t:
        sync_t += textwrap.dedent(r'''

-- v0.5.16-004: Upload local priv/pub and peer pub
local up_local_pub = t:option(FileUpload, "upload_local_pub", translate("Lokalen öffentlichen Schlüssel (.pub) hochladen"))
local up_local_priv = t:option(FileUpload, "upload_local_priv", translate("Lokalen privaten Schlüssel hochladen"))
local up_peer_pub = t:option(FileUpload, "upload_peer_pub", translate("Peer-öffentlichen Schlüssel (.pub) hochladen (trust)"))
up_local_pub.rmempty = true; up_local_priv.rmempty = true; up_peer_pub.rmempty = true

function m.handle(self, state, data)
  if state == FORM_VALID and data then
    if data.upload_local_pub then
      sys.call("mkdir -p /etc/ha-vrrp/keys && cp -f "..util.shellquote(data.upload_local_pub).." /etc/ha-vrrp/keys/local_identity.pub")
    end
    if data.upload_local_priv then
      sys.call("mkdir -p /etc/ha-vrrp/keys && cp -f "..util.shellquote(data.upload_local_priv).." /etc/ha-vrrp/keys/local_identity")
      sys.call("chmod 600 /etc/ha-vrrp/keys/local_identity")
    end
    if data.upload_peer_pub then
      sys.call("mkdir -p /etc/ha-vrrp/keys && cp -f "..util.shellquote(data.upload_peer_pub).." /etc/ha-vrrp/keys/peer_authorized.pub")
    end
  end
  return Map.handle(self, state, data)
end
''')
        write(sync_cbi, sync_t)

# 3d) Instances view: add small description stub
inst_path="luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/instances.lua"
if not os.path.exists(r(inst_path)):
    inst_lua = textwrap.dedent(r'''
local m = Map("ha_vrrp", translate("Instances"))
local s = m:section(SimpleSection, translate("Instanzen Übersicht"))
s.template = "ha_vrrp/instances"
return m
''').strip()+"\n"
    write(inst_path, inst_lua)

inst_view="luci-app-ha-vrrp/luasrc/view/ha_vrrp/instances.htm"
write(inst_view, textwrap.dedent(r'''
<%+header%>
<h2><%:VRRP Instanzen%></h2>
<p><%:Hier siehst du eine kurze Beschreibung zu deinen VRRP-Instanzen. Künftige Versionen listen Details und erlauben Inline-Änderungen.%></p>
<%+footer%>
''').strip()+"\n")

# 4) Docs: README/CHANGELOG/KNOWN_ERRORS per version
ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
docs_dir = "docs"
write(f"{docs_dir}/README_0.5.16-004.md", textwrap.dedent(f"""
# openwrt-ha-vrrp v0.5.16-004

**Datum:** {ts}

## Kurzbeschreibung
Bugfix für LuCI-Views (Overview 500-Fehler behoben), erweiterte Settings (SSH-Backend, CIDR neben Peer-Host),
Sync-Uploads (lokaler privater/öffentlicher Key, Peer-Pub), Versionsanzeige in Overview, Default-Config erweitert.

## Wichtige Änderungen
- Overview-Template nutzt `self.map.uci` statt `m` → behebt 500 Internal Server Error auf 19.07.
- Anzeige der Addon-Version und des SSH-Backends in der Übersicht.
- Settings: neue Felder `ssh_backend` (auto/openssh/dropbear) und `peer_netmask_cidr` (CIDR, z.B. 24).
- Sync: Upload von lokalem privaten Schlüssel, lokalem öffentlichen Schlüssel und Peer-Pub (Trust).
- Instances: kleine Beschreibung (Stub).
- Default `/etc/config/ha_vrrp`: `ssh_backend`, `peer_netmask_cidr`, `cluster_version` ergänzt.

## Hinweise
- Für OpenWrt 19.07 bleibt das UI **serverseitiges CBI** ohne moderne `L.ui`-Widgets; vermeidet den `L.ui is undefined`-Fehler.
- Logs zu Sync-Aktionen: `/tmp/ha_vrrp_*`.
""").strip()+"\n")

write(f"{docs_dir}/CHANGELOG_0.5.16-004.md", textwrap.dedent(f"""
# Changelog v0.5.16-004

- Fix: Overview 500 wegen `m` nil → Template greift nun auf `self.map.uci` zu.
- Neu: Version-/Backend-Anzeige in Overview.
- Neu: Settings um `ssh_backend`, `peer_netmask_cidr` und Hilfetexte erweitert.
- Neu: Sync-Seite unterstützt Upload von privatem Schlüssel (lokal), lokalem Pub und Peer-Pub (Trust).
- Neu: Instances-View mit Kurzbeschreibung (Platzhalter).
- Config: Standardwerte `ssh_backend=auto`, `peer_netmask_cidr=24`, `cluster_version=0.5.16-004`.
""").strip()+"\n")

write(f"{docs_dir}/KNOWN_ISSUES_0.5.16-004.md", textwrap.dedent("""
# Known Issues v0.5.16-004

- JS-basierte LuCI-Formular-Widgets (`L.ui.*`) werden auf OpenWrt 19.07 nicht verwendet; künftige Releases können eine
  separate JS-UI für neuere LuCI-Versionen anbieten.
- Sync-„rsync“-Methode ist UI-seitig auswählbar, Backend-Handler folgt in späterer Subversion.
- Upload von Schlüsseln führt keine Formatvalidierung durch; fehlerhafte Dateien werden stillschweigend übernommen.
""").strip()+"\n")

# aggregate files: append short entries
def agg_append(name, heading, body):
    p=f"{docs_dir}/{name}"
    content=read(p, "")
    content = (content + "\n\n" if content else "") + f"## {heading}\n{body}\n"
    write(p, content)

agg_append("README.md", f"v{variant_new}", "Siehe README_0.5.16-004.md")
agg_append("CHANGELOG.md", f"v{variant_new}", "Siehe CHANGELOG_0.5.16-004.md")
agg_append("KNOWN_ISSUES.md", f"v{variant_new}", "Siehe KNOWN_ISSUES_0.5.16-004.md")

# 5) Build a diff tar (only changed/new files from 0.5.16-002 -> 0.5.16-004)
# Re-unpack base again for comparison
cmp_tmp="/mnt/data/_cmp_0516_004_old"
if os.path.isdir(cmp_tmp): shutil.rmtree(cmp_tmp)
os.makedirs(cmp_tmp, exist_ok=True)
with tarfile.open(BASE_TGZ,"r:gz") as tar:
    tar.extractall(cmp_tmp)
old_root=[os.path.join(cmp_tmp,d) for d in os.listdir(cmp_tmp) if os.path.isdir(os.path.join(cmp_tmp,d))][0]

def relmap(rootdir):
    out={}
    for dp,_,fns in os.walk(rootdir):
        for fn in fns:
            p=os.path.join(dp,fn)
            rel=os.path.relpath(p,rootdir)
            out[rel]=p
    return out

old_map=relmap(old_root)
new_map=relmap(root)
changed=[]
for rel,newp in new_map.items():
    if rel not in old_map:
        changed.append(newp)
    else:
        with open(newp,"rb") as f1, open(old_map[rel],"rb") as f2:
            if f1.read()!=f2.read():
                changed.append(newp)

diff_tar="/mnt/data/openwrt-ha-vrrp-0.5.16-004-diff.tar"
with tarfile.open(diff_tar,"w") as tar:
    for p in changed:
        tar.add(p, arcname=os.path.relpath(p, root))

print(json.dumps({"diff_tar": diff_tar, "changed_files": len(changed)}, indent=2))

