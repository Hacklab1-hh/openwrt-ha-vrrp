#!/bin/sh
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

# genpatch004.sh — Erzeuge Patch, Diff und volle Release-Archive für v0.5.16-004 aus v0.5.16-002
# BusyBox/ash-kompatibel

set -eu

VERSION_OLD="0.5.16-002"
VERSION_NEW="0.5.16-004"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
BASE_NAME="$(basename "$ROOT_DIR")"
PARENT_DIR="$(dirname "$ROOT_DIR")"
WORK_DIR="$PARENT_DIR/_gen_0516_004"

log() { printf '%s\n' "[genpatch04] $*"; }
die() { printf '%s\n' "[genpatch04][ERROR] $*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

need_tools() {
  for t in diff sed awk tar gzip; do
    if ! have "$t"; then
      case "$t" in
        diff)  hint="opkg install diffutils" ;;
        tar)   hint="opkg install tar" ;;
        gzip)  hint="opkg install gzip" ;;
        *)     hint="opkg install $t" ;;
      esac
      die "Benötigtes Tool fehlt: $t (Hinweis: $hint)"
    fi
  done
  have zip || log "Hinweis: zip nicht gefunden, .zip wird übersprungen."
}

copy_tree() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  cp -a "$ROOT_DIR" "$WORK_DIR/old"
  cp -a "$ROOT_DIR" "$WORK_DIR/new"
}

wfile() {
  rel="$1"; shift
  dst="$WORK_DIR/new/$rel"
  mkdir -p "$(dirname "$dst")"
  cat >"$dst"
  chmod 0644 "$dst"
}

append() {
  rel="$1"; shift
  dst="$WORK_DIR/new/$rel"
  mkdir -p "$(dirname "$dst")"
  cat >>"$dst"
  chmod 0644 "$dst"
}

ensure_cfg_core_options() {
  cfg_rel="ha-vrrp/files/etc/config/ha_vrrp"
  cfg="$WORK_DIR/new/$cfg_rel"
  [ -f "$cfg" ] || return 0
  awk -v ver="$VERSION_NEW" '
    BEGIN { in_core=0; seen_ssh=0; seen_cidr=0; seen_ver=0 }
    function inject_missing() {
      if (!seen_ssh)  print "\toption ssh_backend '\''auto'\''"
      if (!seen_cidr) print "\toption peer_netmask_cidr '\''24'\''"
      if (!seen_ver)  print "\toption cluster_version '\''" ver "'\''"
    }
    /^config[ \t]+core[ \t]+'\''core'\''/ { print; in_core=1; next }
    /^config[ \t]+/ {
      if (in_core) { inject_missing(); in_core=0 }
      print; next
    }
    {
      if (in_core) {
        if ($0 ~ /option[ \t]+ssh_backend[ \t]+/) seen_ssh=1
        if ($0 ~ /option[ \t]+peer_netmask_cidr[ \t]+/) seen_cidr=1
        if ($0 ~ /option[ \t]+cluster_version[ \t]+/) seen_ver=1
      }
      print
    }
    END {
      if (in_core) inject_missing()
    }
  ' "$cfg" >"$cfg.tmp" && mv "$cfg.tmp" "$cfg"
}

bump_pkg_versions() {
  for mf in "ha-vrrp/Makefile" "luci-app-ha-vrrp/Makefile"; do
    f="$WORK_DIR/new/$mf"; [ -f "$f" ] || continue
    sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$VERSION_NEW/" "$f"
  done
}

write_controller() {
wfile "luci-app-ha-vrrp/luasrc/controller/ha_vrrp.lua" <<'EOF'
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
EOF
}

write_overview() {
wfile "luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/overview.lua" <<'EOF'
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
EOF

wfile "luci-app-ha-vrrp/luasrc/view/ha_vrrp/overview.htm" <<'EOF'
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
EOF
}

write_settings() {
  rel="luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/settings.lua"
  f="$WORK_DIR/new/$rel"
  if [ -f "$f" ]; then
    grep -q "ssh_backend" "$f" || append "$rel" <<'EOF'

-- v0.5.16-004 additions
local o = s:option(ListValue, 'ssh_backend', translate('SSH-Backend'))
o:value('auto','auto'); o:value('openssh','OpenSSH'); o:value('dropbear','Dropbear')
o.description = translate('Auto erkennt OpenSSH/Dropbear und nutzt bevorzugt OpenSSH wenn verfügbar.')
EOF
    grep -q "peer_netmask_cidr" "$f" || append "$rel" <<'EOF'
local o = s:option(Value, 'peer_netmask_cidr', translate('Peer-Netzmaske (CIDR)'))
o.datatype='ufloat'; o.placeholder='24'
o.description = translate('CIDR-Präfix, z.B. 24 für /24')
EOF
  else
wfile "$rel" <<'EOF'
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
EOF
  fi
}

write_sync() {
  rel="luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/sync.lua"
  f="$WORK_DIR/new/$rel"
  if [ -f "$f" ]; then
    grep -q "upload_local_priv" "$f" || append "$rel" <<'EOF'

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
EOF
  else
wfile "$rel" <<'EOF'
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
EOF
  fi

wfile "luci-app-ha-vrrp/luasrc/view/ha_vrrp/sync.htm" <<'EOF'
<%+header%>
<h2><%:Sync und Keys%></h2>
<p><%:Erzeuge/verwende SSH-Schlüssel für den Config-Sync zwischen Cluster-Nodes.
Dropbear und OpenSSH werden automatisch erkannt. ED25519 wird bevorzugt, wenn unterstützt; sonst RSA.%></p>
<p><%:Protokoll-Ausgaben findest du in /tmp/ha_vrrp_*.%></p>
<%+footer%>
EOF
}

write_instances() {
wfile "luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/instances.lua" <<'EOF'
local m = Map("ha_vrrp", translate("Instances"))
local s = m:section(SimpleSection, translate("Instanzen Übersicht"))
s.template = "ha_vrrp/instances"
return m
EOF

wfile "luci-app-ha-vrrp/luasrc/view/ha_vrrp/instances.htm" <<'EOF'
<%+header%>
<h2><%:VRRP Instanzen%></h2>
<p><%:Hier siehst du eine kurze Beschreibung zu deinen VRRP-Instanzen. Künftige Versionen listen Details und erlauben Inline-Änderungen.%></p>
<%+footer%>
EOF
}

write_docs() {
  TS="$(date '+%Y-%m-%d %H:%M:%S')"
  mkdir -p "$WORK_DIR/new/docs"
wfile "docs/README_0.5.16-004.md" <<EOF
# openwrt-ha-vrrp v$VERSION_NEW

**Datum:** $TS

## Kurzbeschreibung
Bugfix für LuCI-Views (Overview 500-Fehler behoben), erweiterte Settings (SSH-Backend, CIDR neben Peer-Host),
Sync-Uploads (lokaler privater/öffentlicher Key, Peer-Pub), Versionsanzeige in Overview, Default-Config erweitert.

## Wichtige Änderungen
- Overview-Template nutzt \`self.map.uci\` statt \`m\` → behebt 500 Internal Server Error auf 19.07.
- Anzeige der Addon-Version und des SSH-Backends in der Übersicht.
- Settings: neue Felder \`ssh_backend\` (auto/openssh/dropbear) und \`peer_netmask_cidr\` (CIDR, z.B. 24).
- Sync: Upload von lokalem privaten Schlüssel, lokalem Pub und Peer-Pub (Trust).
- Instances: kleine Beschreibung (Stub).
- Default \`/etc/config/ha_vrrp\`: \`ssh_backend\`, \`peer_netmask_cidr\`, \`cluster_version\` ergänzt.

## Hinweise
- Für OpenWrt 19.07 bleibt das UI serverseitiges CBI ohne moderne \`L.ui\`-Widgets; vermeidet den \`L.ui is undefined\`-Fehler.
- Logs zu Sync-Aktionen: \`/tmp/ha_vrrp_*\`.
EOF

wfile "docs/CHANGELOG_0.5.16-004.md" <<'EOF'
# Changelog v0.5.16-004

- Fix: Overview 500 wegen `m` nil → Template greift nun auf `self.map.uci` zu.
- Neu: Version-/Backend-Anzeige in Overview.
- Neu: Settings um `ssh_backend`, `peer_netmask_cidr` und Hilfetexte erweitert.
- Neu: Sync-Seite unterstützt Upload von privatem Schlüssel (lokal), lokalem Pub und Peer-Pub (Trust).
- Neu: Instances-View mit Kurzbeschreibung (Platzhalter).
- Config: Standardwerte `ssh_backend=auto`, `peer_netmask_cidr=24`, `cluster_version=0.5.16-004`.
EOF

wfile "docs/KNOWN_ISSUES_0.5.16-004.md" <<'EOF'
# Known Issues v0.5.16-004

- JS-basierte LuCI-Formular-Widgets (`L.ui.*`) werden auf OpenWrt 19.07 nicht verwendet; künftige Releases können eine
  separate JS-UI für neuere LuCI-Versionen anbieten.
- Sync-„rsync“-Methode ist UI-seitig auswählbar, Backend-Handler folgt in späterer Subversion.
- Upload von Schlüsseln führt keine Formatvalidierung durch; fehlerhafte Dateien werden stillschweigend übernommen.
EOF

  for a in README.md CHANGELOG.md KNOWN_ISSUES.md; do
    agg="$WORK_DIR/new/docs/$a"
    : >"$agg"
    {
      echo "## v$VERSION_NEW"
      case "$a" in
        README.md)       echo "Siehe README_$VERSION_NEW.md" ;;
        CHANGELOG.md)    echo "Siehe CHANGELOG_$VERSION_NEW.md" ;;
        KNOWN_ISSUES.md) echo "Siehe KNOWN_ISSUES_$VERSION_NEW.md" ;;
      esac
    } >>"$agg"
  done
}

build_patch_and_diff() {
  OUT_PATCH="$PARENT_DIR/openwrt-ha-vrrp-$VERSION_OLD"_to_"$VERSION_NEW.patch"
  OUT_DIFFTAR="$PARENT_DIR/openwrt-ha-vrrp-$VERSION_NEW-diff.tar"

  log "Erzeuge Unified-Diff: $OUT_PATCH"
  (cd "$WORK_DIR" && diff -ruN "old" "new" > "$OUT_PATCH" || true)

  log "Erzeuge Diff-Tar: $OUT_DIFFTAR"
  TMP_LIST="$(mktemp)"
  (
    cd "$WORK_DIR"
    diff -ruN old new 2>/dev/null \
      | while IFS= read -r line; do
          case "$line" in
            "diff -ruN "*)
              rel="${line#* new/}"
              [ -n "$rel" ] && printf '%s\n' "$rel"
              ;;
            "Only in new/"*)
              l="${line#Only in new/}"
              dir="${l%%:*}"
              file="${l#*: }"
              [ -n "$dir" ] && [ -n "$file" ] && printf '%s/%s\n' "$dir" "$file"
              ;;
          esac
        done
  ) | sed '/^$/d' | sort -u >"$TMP_LIST"

  ( cd "$WORK_DIR/new" && tar -cf "$OUT_DIFFTAR" -T "$TMP_LIST" )
  rm -f "$TMP_LIST"
}

build_full_archives() {
  NEWROOT_BASENAME="$(echo "$BASE_NAME" | sed "s/$VERSION_OLD/$VERSION_NEW/")"
  NEWROOT_PATH="$PARENT_DIR/$NEWROOT_BASENAME"
  rm -rf "$NEWROOT_PATH"
  cp -a "$WORK_DIR/new" "$NEWROOT_PATH"
  TAR_GZ="$PARENT_DIR/$NEWROOT_BASENAME.tar.gz"
  TAR_FLAT="$PARENT_DIR/$NEWROOT_BASENAME.tar"
  ZIP_FLAT="$PARENT_DIR/$NEWROOT_BASENAME.zip"

  log "Packe volle Archive (tar.gz / tar / zip) unter: $PARENT_DIR"
  (cd "$PARENT_DIR" && tar -czf "$TAR_GZ" "$NEWROOT_BASENAME")
  (cd "$PARENT_DIR" && tar -cf  "$TAR_FLAT" "$NEWROOT_BASENAME")
  if have zip; then
    (cd "$PARENT_DIR" && zip -qr "$ZIP_FLAT" "$NEWROOT_BASENAME")
  else
    log "zip nicht vorhanden — .zip wird übersprungen."
  fi
  log "Full  : $NEWROOT_BASENAME.{tar.gz,tar,zip}"
}

main() {
  need_tools
  log "Arbeitsbaum kopieren nach $WORK_DIR/{old,new} …"
  copy_tree

  log "Defaults in /etc/config/ha_vrrp ergänzen …"
  ensure_cfg_core_options

  log "Makefile-Versionen bumpen auf $VERSION_NEW …"
  bump_pkg_versions

  log "LuCI Controller/Views/CBIs schreiben …"
  write_controller
  write_overview
  write_settings
  write_sync
  write_instances

  log "Dokumentation schreiben …"
  write_docs

  log "Erzeuge Ausgaben …"
  build_patch_and_diff
  build_full_archives

  log "Fertig."
  log "Patch : $PARENT_DIR/openwrt-ha-vrrp-$VERSION_OLD"_to_"$VERSION_NEW.patch"
  log "Diff  : $PARENT_DIR/openwrt-ha-vrrp-$VERSION_NEW-diff.tar"
}

main "$@"

