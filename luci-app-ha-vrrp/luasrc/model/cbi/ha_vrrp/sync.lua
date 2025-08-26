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

o = t:option(ListValue, "key_type", translate("Bevorzugter Schlüsseltyp"))
o:value("auto", "auto (ed25519 bevorzugt)")
o:value("ed25519", "ed25519")
o:value("rsa", "rsa")
o.default = "auto"

o = t:option(ListValue, "sync_method", translate("Sync-Methode"))
o:value("auto", "auto")
o:value("scp", "scp")
o:value("rsync", "rsync")
o.default = "auto"

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

local up = t:option(FileUpload, "upload_pubkey", translate("Öffentlichen Schlüssel hochladen (.pub)"))
up.rmempty = true
function m.handle(self, state, data)
  if state == FORM_VALID and data and data.upload_pubkey then
    sys.call("mkdir -p /etc/ha-vrrp/keys && cp -f "..util.shellquote(data.upload_pubkey).." /etc/ha-vrrp/keys/authorized_pub_upload.pub")
  end
  return Map.handle(self, state, data)
end

return m

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
