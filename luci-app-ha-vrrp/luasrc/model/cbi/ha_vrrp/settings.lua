local m = Map("ha_vrrp", translate("Settings"))
local s = m:section(NamedSection, "core", "core", translate("Core Settings"))

local o
o = s:option(Value, "cluster_name", translate("Cluster Name"))
o.placeholder = "YOURCLUSTER"

o = s:option(Value, "peer_host", translate("Peer Host (IP/Name)"))
o.placeholder = "192.168.254.2"

o = s:option(ListValue, "fw_backend", translate("Firewall Backend"))
o:value("auto", "auto"); o:value("iptables", "iptables"); o:value("nft", "nft")

o = s:option(ListValue, "ka_backend", translate("Keepalived Backend"))
o:value("auto", "auto"); o:value("ka_2x", "ka_2x"); o:value("ka_2_2plus", "ka_2_2plus")

o = s:option(ListValue, "dhcp_backend", translate("DHCP/DNS Backend"))
o:value("auto", "auto"); o:value("dnsmasq_legacy", "dnsmasq_legacy"); o:value("dnsmasq_fw4", "dnsmasq_fw4")

o = s:option(ListValue, "net_backend", translate("Netzwerk Backend"))
o:value("auto", "auto"); o:value("swconfig", "swconfig"); o:value("dsa", "dsa")

return m

-- v0.5.16-004 additions
local o = s:option(ListValue, 'ssh_backend', translate('SSH-Backend'))
o:value('auto','auto'); o:value('openssh','OpenSSH'); o:value('dropbear','Dropbear')
o.description = translate('Auto erkennt OpenSSH/Dropbear und nutzt bevorzugt OpenSSH wenn verfügbar.')
local o = s:option(Value, 'peer_netmask_cidr', translate('Peer-Netzmaske (CIDR)'))
o.datatype='ufloat'; o.placeholder='24'
o.description = translate('CIDR-Präfix, z.B. 24 für /24')
