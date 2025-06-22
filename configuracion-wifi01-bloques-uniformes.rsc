# ================================================
# Configuración de MikroTik
# ROS: 7.19.1
# Descripción: VLAN, Cola, PCQ, Firewall ultra seguro
# Autor: Carlos Dagorret
# Fecha: 22/6/2025
# ================================================
# MikroTik Configuration
# ROS: 7.19.1
# Description: VLAN, Queue, PCQ, Ultra-secure Firewall
# Author: Carlos Dagorret
# Date: 2025-06-22
# ================================================



# 1000 - Configuración intermedia
# 1000 - Intermediate config
# Comandos previos a definición de interfaces
# Intermediate routing or bridge commands


# 1000 - Configuración general previa
# 1000 - General preliminary settings
# 2025-06-22 14:04:56 by RouterOS 7.19.1


# 1100 - Configuración del bridge
# 1100 - Bridge configuration


# 1000 - Definición de VLAN
# 1000 - VLAN definition
# VLAN 100 para red de invitados
# VLAN 100 for isolated guest network
/interface bridge
add admin-mac=D4:01:C3:3C:BC:BD auto-mac=no comment=defconf name=bridge


# 1200 - Configuración de VLAN
# 1200 - VLAN configuration
/interface ethernet
set [ find default-name=ether1 ] mac-address=5C:10:10:9B:64:13
/interface wifi
set [ find default-name=wifi1 ] channel.band=2ghz-ax .frequency="" \
    .skip-dfs-channels=10min-cac .width=20/40mhz-eC \
    configuration.antenna-gain=5 .mode=ap .ssid=Tronador-L .tx-power=23 \
    datapath.bridge=bridge disabled=no mtu=1500 name=wifi-lan \
    security.authentication-types=wpa2-psk,wpa3-psk .ft=yes .ft-over-ds=yes
/interface wireguard
add comment=back-to-home-vpn listen-port=21718 mtu=1420 name=back-to-home-vpn


# 1300 - Configuración general previa
# 1300 - General preliminary settings


# 1000 - Servidor DHCP
# 1000 - DHCP Server
# Asigna IPs dinámicas a clientes
# Assigns dynamic IPs to clients
/interface vlan
add interface=bridge name=vlan100 vlan-id=100
/interface wifi
add configuration.mode=ap .ssid=ValleSur-100 datapath.bridge=bridge .vlan-id=\
    100 disabled=no mac-address=D6:01:C3:3C:BC:C6 master-interface=wifi-lan \
    mtu=1500 name=wifi-guest security.authentication-types=""
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface wifi channel
add band=2ghz-ax frequency=2462 name=ch-11 width=20/40mhz-Ce
add band=2ghz-ax frequency=2412 name=ch-guest-1 width=20/40mhz-Ce
/interface wifi datapath
add bridge=bridge name=dp-lan
add bridge=bridge name=dp-guest
/interface wifi security
add authentication-types=wpa2-psk,wpa3-psk name=sec-lan
add authentication-types=wpa2-psk,wpa3-psk name=sec-guest
/interface wifi configuration
add channel=ch-11 channel.band=2ghz-ax .width=20/40mhz-Ce country=Argentina \
    datapath=dp-lan mode=ap name=cfg-lan security=sec-lan ssid=TronadorNet
add channel=ch-guest-1 country=Argentina datapath=dp-guest mode=ap name=\
    cfg-guest security=sec-guest ssid=ValleSur
/ip pool
add name=dhcp ranges=10.1.1.1-10.1.15.254
add name=pool-v100 ranges=10.100.100.10-10.100.100.100
add name=pool-vlan100 ranges=10.100.100.10-10.100.100.254


# 1000 - Configuración intermedia
# 1000 - Intermediate config
# Comandos previos a definición de interfaces
# Intermediate routing or bridge commands
/ip dhcp-server
add address-pool=dhcp interface=bridge name=defconf
add address-pool=pool-vlan100 interface=vlan100 lease-time=1h name=dhcpd-100
/port
set 0 name=serial0
/queue type
add kind=pcq name=pcq-download-guest pcq-classifier=dst-address pcq-rate=10M
add kind=pcq name=pcq-upload-guest pcq-classifier=src-address pcq-rate=5M
/queue simple
add comment="Limitar ancho de banda total e individual para wifi-guest" \
    max-limit=10M/30M name=queue01 queue=pcq-download-guest/pcq-upload-guest \
    target=10.100.100.0/24
add comment="Limitar ancho de banda total e individual para wifi-guest" name=\
    queue00 priority=1/1 queue=ethernet-default/ethernet-default target=\
    10.1.0.0/20
/certificate settings
set builtin-trust-anchors=not-trusted
/disk settings
set auto-media-interface=bridge auto-media-sharing=yes auto-smb-sharing=yes


# 1400 - Configuración general previa
# 1400 - General preliminary settings


# 1000 - Configuración intermedia
# 1000 - Intermediate config
# Comandos previos a definición de interfaces
# Intermediate routing or bridge commands
/interface bridge filter
add action=drop chain=forward in-interface=*D
add action=drop chain=forward out-interface=*D


# 1500 - Configuración general previa
# 1500 - General preliminary settings


# 1000 - Configuración intermedia
# 1000 - Intermediate config
# Comandos previos a definición de interfaces
# Intermediate routing or bridge commands
/interface bridge port
add bridge=bridge comment=defconf interface=ether2
add bridge=bridge comment=defconf interface=ether3
add bridge=bridge comment=defconf interface=ether4
add bridge=bridge comment=defconf interface=ether5
add bridge=bridge comment=defconf interface=ether6
add bridge=bridge comment=defconf interface=ether7
add bridge=bridge comment=defconf interface=ether8
add bridge=bridge comment=defconf interface=sfp1
add bridge=bridge comment=defconf interface=wifi-lan
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged \
    interface=wifi-guest pvid=100
/ip neighbor discovery-settings
set discover-interface-list=LAN


# 1600 - Configuración final
# 1600 - Final configuration


# 1000 - Servidor DHCP
# 1000 - DHCP Server
# Asigna IPs dinámicas a clientes
# Assigns dynamic IPs to clients
/interface bridge vlan
add bridge=bridge tagged=bridge untagged=\
    ether2,ether3,ether4,ether5,ether6,ether7,ether8,wifi-lan vlan-ids=1
add bridge=bridge tagged=bridge untagged=wifi-guest vlan-ids=100
/interface detect-internet
set detect-interface-list=all
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=ether1 list=WAN
add interface=vlan100 list=LAN
/ip address
add address=10.1.0.1/20 comment=defconf interface=bridge network=10.1.0.0
add address=10.100.100.1/24 interface=vlan100 network=10.100.100.0
/ip cloud
set back-to-home-vpn=enabled ddns-enabled=yes ddns-update-interval=10m
/ip cloud back-to-home-user
add allow-lan=yes comment=L009UiGS-2HaxD file-access=full file-access-path=\
    /nas name=ToC private-key="kHq6ZAYlwYFnJoWU9TaWuJO5DAO98gmmaEoEc3oQ5Xk=" \
    public-key="K9lXui2bIHKSS4a/D9TYDs0xaRzyacMRZ7JcEwB37yI="
/ip dhcp-client
add comment=defconf interface=ether1 use-peer-dns=no use-peer-ntp=no


# 1000 - Servidor DHCP
# 1000 - DHCP Server
# Asigna IPs dinámicas a clientes
# Assigns dynamic IPs to clients
/ip dhcp-server lease
add address=10.1.0.2 client-id=1:88:ae:dd:6:92:92 mac-address=\
    88:AE:DD:06:92:92 server=defconf


# 1000 - Firewall y NAT
# 1000 - Firewall and NAT
# Control de tráfico entre redes y reglas de NAT
# Traffic control and NAT between networks
/ip dhcp-server network
add address=10.1.0.0/20 comment=defconf dns-server=10.1.0.1 gateway=10.1.0.1 \
    netmask=20
add address=10.100.100.0/24 dns-server=10.1.0.1 gateway=10.100.100.1 netmask=\
    24 ntp-server=10.100.100.1
/ip dns
set allow-remote-requests=yes cache-size=26000KiB servers=\
    208.67.222.222,208.67.220.220 use-doh-server=\
    https://dns.quad9.net/dns-query
/ip dns adlist
add ssl-verify=no url="https://raw.githubusercontent.com/hagezi/dns-blocklists\
    /main/domains/multi.txt"


# 1000 - Firewall y NAT
# 1000 - Firewall and NAT
# Control de tráfico entre redes y reglas de NAT
# Traffic control and NAT between networks
/ip firewall filter
add action=drop chain=input comment="\?\?" dst-address=10.1.0.1 dst-port=!53 \
    protocol=tcp src-address=10.100.100.0/24
add action=drop chain=input comment="\?\?" dst-address=10.1.0.1 dst-port=!53 \
    protocol=udp src-address=10.100.100.0/24
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related hw-offload=yes
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked disabled=yes
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=accept chain=input comment="Permitir DNS TCP invitados  al MK" \
    dst-address=10.1.0.1 dst-port=53 protocol=tcp src-address=10.100.100.0/24
add action=accept chain=forward comment="Permitir DNS TCP invitados  AdGuard" \
    disabled=yes dst-address=10.1.0.2 dst-port=53 protocol=tcp src-address=\
    10.100.100.0/24
add action=accept chain=forward comment="Permitir DNS UDP invitados  AdGuard" \
    disabled=yes dst-address=10.1.0.2 dst-port=53 protocol=udp src-address=\
    10.100.100.0/24
add action=drop chain=forward comment="Bloquear acceso invitados a red LAN" \
    dst-address=10.1.0.0/20 src-address=10.100.100.0/24
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN
add action=drop chain=forward comment="denegar todo lo demas" disabled=yes
add action=accept chain=input comment="Permitir DNS TCP invitados  al.MK" \
    dst-address=10.1.0.1 dst-port=53 protocol=udp src-address=10.100.100.0/24


# 1000 - Comandos finales
# 1000 - Final commands
# Configuraciones finales no clasificadas
# Final ungrouped configurations
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN
add action=masquerade chain=srcnat comment=\
    "N1 - NAT para invitados (VLAN100)" out-interface=ether1 src-address=\
    10.100.100.0/24
add action=redirect chain=dstnat comment=\
    "Redirigir DNS UDP desde LAN al MikroTik" dst-port=53 protocol=udp \
    src-address=10.1.0.0/20 to-ports=53
add action=redirect chain=dstnat comment=\
    "Redirigir DNS TCP desde LAN al MikroTik" dst-port=53 protocol=tcp \
    src-address=10.1.0.0/20 to-ports=53
add action=redirect chain=dstnat comment=\
    "Redirigir DNS UDP desde VLAN 100 al MikroTik" dst-port=53 protocol=udp \
    src-address=10.100.100.0/24 to-ports=53
add action=redirect chain=dstnat comment=\
    "Redirigir DNS TCP desde VLAN 100 al MikroTik" dst-port=53 protocol=tcp \
    src-address=10.100.100.0/24 to-ports=53
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" \
    dst-port=33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=fasttrack-connection chain=forward comment="defconf: fasttrack6" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
/system clock
set time-zone-name=America/Argentina/Buenos_Aires
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes
/system ntp client servers
add address=0.pool.ntp.org
add address=1.pool.ntp.org
add address=2.pool.ntp.org
add address=3.pool.ntp.org
/system routerboard settings
set enter-setup-on=delete-key
/tool graphing interface
add
/tool graphing queue
add
/tool graphing resource
add
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
