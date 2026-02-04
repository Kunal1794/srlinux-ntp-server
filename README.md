# Srlinux-NTP-Server
SR Linux as NTP Server – Chrony Configuration per VRF
This repository provides a working example and configuration framework to run SR Linux (SRL) as an NTP server using Linux chrony, including support for:
* Per-VRF NTP instances
* Source IP binding
* Loopback-based NTP services
* Systemd service separation
* Chrony process isolation

## Topology
<img width="1240" height="399" alt="image" src="https://github.com/user-attachments/assets/ea9c4e31-d7ec-4105-8748-a58dbcefb9a4" />

## Steps to deploy CLAB
```
containerlab deploy -t srlinux-ntp-server.yml
```
## Steps to destroy CLAB
```
containerlab destroy -t srlinux-ntp-server.yml -c
```

## Post Deployment Steps
After the Containerlab topology is successfully deployed, a few manual configuration steps are required on the SR Linux node, NTP Server, and Client2 to start the chrony services and validate NTP functionality.
Follow the steps below in sequence:

### SRL
Login to the SR Linux node:
```
ssh clab-srlinux-ntp-server-srl
```
Switch to bash shell with root privileges & Start chrony instances inside the required network namespaces:
```
bash sudo bash
sudo ip netns exec srbase-default chronyd -f /etc/opt/srlinux/ntp-default.conf -r
sudo ip netns exec srbase-ip-vrf1 chronyd -f /etc/opt/srlinux/ntp-ip-vrf1.conf -r
```
(Optional) Manually Set System Date
If required for testing, you can manually set the system date before NTP synchronization:
```
date 020323332026.00   #date MMDDHHMiMiYYYY.SS
```
### NTP-Server
Login to the NTP Server node:
```
ssh clab-srlinux-ntp-server-server
```
Password - Nokia@123

Start the chrony daemon in debug mode:
```
chronyd -f /etc/chrony/chrony.conf -d &
```
### Client2
```
ssh clab-srlinux-ntp-server-client2
```
Password - Nokia@123
```
 chronyd -f /etc/chrony/chrony.conf
```

## Verification

### NTP-Server
```
chronyc sources && echo && chronyc tracking && echo &&  chronyc -n clients
```
```
210 Number of sources = 0
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================

Reference ID    : 7F7F0101 ()
Stratum         : 10
Ref time (UTC)  : Wed Feb 04 04:47:41 2026
System time     : 0.000000000 seconds fast of NTP time
Last offset     : +0.000000000 seconds
RMS offset      : 0.000000000 seconds
Frequency       : 286.484 ppm slow
Residual freq   : +0.000 ppm
Skew            : 0.000 ppm
Root delay      : 0.000000000 seconds
Root dispersion : 0.000000000 seconds
Update interval : 0.0 seconds
Leap status     : Normal

Hostname                      NTP   Drop Int IntL Last     Cmd   Drop Int  Last
===============================================================================
1.1.1.1                       330      0   6   -    11       0      0   -     -
2.2.2.2                       384      0   6   -    45       0      0   -     -
```
### SRL
```
ps aux | grep chronyd
```
```
_chrony     7421  0.0  0.0  10552  2240 ?        S    21:15   0:00 chronyd -f /etc/opt/srlinux/ntp-default.conf -r
_chrony     7600  0.0  0.0  10552  2240 ?        S    21:15   0:00 chronyd -f /etc/opt/srlinux/ntp-ip-vrf1.conf -r
admin       7678  0.0  0.0   6308  1600 pts/9    S+   21:15   0:00 grep chronyd
```
```
sudo ip netns exec srbase-default ss -tulpn
```
```
Netid       State        Recv-Q       Send-Q             Local Address:Port             Peer Address:Port       Process                                  
udp         UNCONN       0            0                        1.1.1.1:123                   0.0.0.0:*           users:(("chronyd",pid=7421,fd=7))       
udp         UNCONN       0            0                      127.0.0.1:323                   0.0.0.0:*           users:(("chronyd",pid=7421,fd=5))       
udp         UNCONN       0            0                           [::]:123                      [::]:*           users:(("chronyd",pid=7421,fd=8))       
udp         UNCONN       0            0                          [::1]:323                      [::]:*           users:(("chronyd",pid=7421,fd=6))
```
```    
sudo ip netns exec srbase-ip-vrf1 ss -tulpn
```
```
Netid       State        Recv-Q       Send-Q             Local Address:Port             Peer Address:Port       Process                                  
udp         UNCONN       0            0                        2.2.2.2:123                   0.0.0.0:*           users:(("chronyd",pid=7600,fd=7))       
udp         UNCONN       0            0                      127.0.0.1:323                   0.0.0.0:*           users:(("chronyd",pid=7600,fd=5))       
udp         UNCONN       0            0                           [::]:123                      [::]:*           users:(("chronyd",pid=7600,fd=8))       
udp         UNCONN       0            0                          [::1]:323                      [::]:*           users:(("chronyd",pid=7600,fd=6))
```
```
chronyc sources && echo && chronyc tracking && echo && sudo chronyc -n clients
```
```
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^* 100.100.100.100              10   6   377    29   +170us[ +492us] +/-  944us

Reference ID    : 64646464 (100.100.100.100)
Stratum         : 11
Ref time (UTC)  : Wed Feb 04 04:49:05 2026
System time     : 0.000085323 seconds fast of NTP time
Last offset     : +0.000321132 seconds
RMS offset      : 0.000198661 seconds
Frequency       : 25.330 ppm slow
Residual freq   : +0.466 ppm
Skew            : 2.943 ppm
Root delay      : 0.001888525 seconds
Root dispersion : 0.000269026 seconds
Update interval : 64.7 seconds
Leap status     : Normal

Hostname                      NTP   Drop Int IntL Last     Cmd   Drop Int  Last
===============================================================================
50.50.50.50                    32      0   8   -   136       0      0   -     -
```
> However, when using chronyc tracking/clients, only one VRF client is visible.
This is because chronyc connects to the control socket of the one VRF chronyd instance.
I assume that other chronyd instance does not expose its client list via the shared socket.
Functionally everything works as expected - only the visibility in chronyc is limited. 
Though you can check NTP packets via tcpdump command or else verify the NTP sync on the clients.
```
sudo ip netns exec srbase-ip-vrf1 tcpdump -ni any udp port 123
sudo ip netns exec srbase-default tcpdump -ni any udp port 123
```

### Client1
```
info from state system ntp
```
Srl Password - NokiaSrl1!
```
    admin-state enable
    oper-state up
    synchronized 1.1.1.1
    network-instance default
    server 1.1.1.1 {
        iburst true
        prefer true
        stratum 11
        jitter 0
        offset 90
        root-delay 0
        root-dispersion 0
        poll-interval 512
    }
```
### Client2
```
client2:~# chronyc tracking
```
```
Reference ID    : 02020202 (2.2.2.2)
Stratum         : 12
Ref time (UTC)  : Wed Feb 04 04:42:56 2026
System time     : 0.000002838 seconds slow of NTP time
Last offset     : +0.000024928 seconds
RMS offset      : 0.000112404 seconds
Frequency       : 217.363 ppm slow
Residual freq   : +0.002 ppm
Skew            : 0.179 ppm
Root delay      : 0.001464037 seconds
Root dispersion : 0.000628291 seconds
Update interval : 256.3 seconds
Leap status     : Normal
```
