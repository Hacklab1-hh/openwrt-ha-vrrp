# Two-instance setup (HB on VLAN200 + LAN VIP 192.168.1.254)

# Node A
uci set ha_vrrp.core.enabled='1'
uci set ha_vrrp.core.cluster_name='lab-ha'
uci set ha_vrrp.core.auth_pass='changeme-please'

uci -q delete ha_vrrp.inst_hb
uci set ha_vrrp.inst_hb='instance'
uci set ha_vrrp.inst_hb.name='HB'
uci set ha_vrrp.inst_hb.vrid='42'
uci set ha_vrrp.inst_hb.priority='150'
uci set ha_vrrp.inst_hb.state='MASTER'
uci set ha_vrrp.inst_hb.preempt='1'
uci set ha_vrrp.inst_hb.advert_int='1'
uci set ha_vrrp.inst_hb.iface='eth0'
uci set ha_vrrp.inst_hb.use_vlan='1'
uci set ha_vrrp.inst_hb.vlan_id='200'
uci set ha_vrrp.inst_hb.vip_cidr='192.168.200.254/24'
uci set ha_vrrp.inst_hb.unicast_src_ip='192.168.200.1'
uci -q del_list ha_vrrp.inst_hb.unicast_peer
uci add_list ha_vrrp.inst_hb.unicast_peer='192.168.200.2'

uci -q delete ha_vrrp.inst_lan
uci set ha_vrrp.inst_lan='instance'
uci set ha_vrrp.inst_lan.name='LAN'
uci set ha_vrrp.inst_lan.vrid='41'
uci set ha_vrrp.inst_lan.priority='150'
uci set ha_vrrp.inst_lan.state='MASTER'
uci set ha_vrrp.inst_lan.preempt='1'
uci set ha_vrrp.inst_lan.advert_int='1'
uci set ha_vrrp.inst_lan.iface='br-lan'
uci set ha_vrrp.inst_lan.vip_cidr='192.168.1.254/24'
uci set ha_vrrp.inst_lan.unicast_src_ip='192.168.1.1'
uci -q del_list ha_vrrp.inst_lan.unicast_peer
uci add_list ha_vrrp.inst_lan.unicast_peer='192.168.1.2'

uci commit ha_vrrp
/usr/libexec/ha-vrrp/ensure_vlan.sh
/usr/sbin/ha-vrrp-apply
/etc/init.d/keepalived restart

# Node B: analogous with priority=100, state=BACKUP, src_ip and peer swapped.
