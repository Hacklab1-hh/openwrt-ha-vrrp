module("luci.controller.ha_vrrp", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/ha_vrrp") then return end
	entry({"admin","services","ha_vrrp"}, firstchild(), _("HA VRRP"), 50).dependent = true
	entry({"admin","services","ha_vrrp","status"}, template("ha_vrrp/status"), _("Status"), 1).leaf = true
	entry({"admin","services","ha_vrrp","config"}, cbi("ha_vrrp/main"), _("Konfiguration"), 2).leaf = true
	entry({"admin","services","ha_vrrp","apply"}, call("apply"), nil).leaf = true
end

function apply()
	local http = require "luci.http"
	local ok = (os.execute("/usr/sbin/ha-vrrp-apply >/tmp/ha_vrrp.out 2>&1") == 0)
	if ok then os.execute("/etc/init.d/keepalived restart >/dev/null 2>&1") end
	http.prepare_content("application/json")
	http.write_json({ ok = ok })
end
