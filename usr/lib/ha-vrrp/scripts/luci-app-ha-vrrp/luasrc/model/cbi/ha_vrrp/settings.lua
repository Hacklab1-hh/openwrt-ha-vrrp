local m = Map("ha_vrrp", translate("Settings"))
local s = m:section(NamedSection, "core", "core", translate("Core Settings"))

local o
o = s:option(Value, "cluster_name", translate("Cluster Name"))
o.placeholder = "YOURCLUSTER"
o.rmempty = false

o = s:option(Value, "peer_host", translate("Peer Host (IP/Name)"))
o.placeholder = "192.168.254.2"
o.datatype = "host"

o = s:option(ListValue, "fw_backend", translate("Firewall Backend"))
o:value("auto", "auto"); o:value("iptables", "iptables"); o:value("nft", "nft")

o = s:option(ListValue, "ka_backend", translate("Keepalived Backend"))
o:value("auto", "auto"); o:value("ka_2x", "keepalived 2.x"); o:value("ka_2_2plus", "keepalived >= 2.2")

o = s:option(ListValue, "dhcp_backend", translate("DHCP/DNS Backend"))
o:value("auto", "auto"); o:value("dnsmasq_legacy", "dnsmasq (fw3)"); o:value("dnsmasq_fw4", "dnsmasq (fw4)")

return m
