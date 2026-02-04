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
