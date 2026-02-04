ip link add link eth1 name eth1.10 type vlan id 10
ip link add link eth1 name eth1.20 type vlan id 20
ip link set eth1.10 up
ip link set eth1.20 up
ip link add dummy0 type dummy
ip link set dummy0 up
export HTTP_PROXY="http://inban1b-proxy.apac.nsn-net.net:8080"
export HTTPS_PROXY="http://inban1b-proxy.apac.nsn-net.net:8080"
echo -e "PermitRootLogin yes\nPubkeyAuthentication yes\nAuthorizedKeysFile .ssh/authorized_keys\nPasswordAuthentication yes\nPermitEmptyPasswords yes\nAllowTcpForwarding no\nGatewayPorts no\nX11Forwarding no\nSubsystem sftp /usr/lib/ssh/sftp-server" | tee /etc/ssh/sshd_config > /dev/null
echo "root:Nokia@123" | chpasswd
apk add openssh
ssh-keygen -A
/usr/sbin/sshd
apk add chrony
apk add tzdata
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

