# Examples for Lamobo R1 (BPI) – dual-node HA

Segments:
- ADMINLAN 192.168.1.0/24 – node1=192.168.1.1, node2=192.168.1.2, VIP=192.168.1.254
- GAST     192.168.4.0/24 – node1=192.168.4.1, node2=192.168.4.2, VIP=192.168.4.254
- HEARTBEAT (VLAN 200 on eth0) 192.168.254.0/24 – node1=192.168.254.1, node2=192.168.254.2, VIP=192.168.254.254

Health:
- IPv4 WAN check on `wan` (DHCP gateway)
- (optional) IPv6 WAN check on `wan6`

Use:
1) Copy the script to the node and run as root: `sh ./apply-LamoboR1-1.sh` or `sh ./apply-LamoboR1-2.sh`
2) Open LuCI → Services → HA VRRP and verify status.
