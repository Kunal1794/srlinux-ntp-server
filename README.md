# srlinux-ntp-server
SRL as NTP server

## Topology
<img width="1240" height="399" alt="image" src="https://github.com/user-attachments/assets/ea9c4e31-d7ec-4105-8748-a58dbcefb9a4" />

## Steps to deploy CLAB
```
containerlab deploy -t srlinux-ntp-server.yml
```
## Steps to deploy CLAB
```
containerlab destroy -t srlinux-ntp-server.yml -c
```

## Post Deployment Steps
Need to configure SRL, Server & Client2 post clab deployment, here is the below steps

### SRL
```
ssh clab-srlinux-ntp-server-srl
```
```
bash sudo bash
sudo ip netns exec srbase-default chronyd -f /etc/opt/srlinux/ntp-default.conf -r
sudo ip netns exec srbase-ip-vrf1 chronyd -f /etc/opt/srlinux/ntp-ip-vrf1.conf -r
```
### NTP-Server
```
ssh clab-srlinux-ntp-server-server
```
Password - Nokia@123
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
