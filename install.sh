#!/bin/bash
[ $(id -u) != 0 ] && (echo "Please run as root user!" && exit 1)
IP=$(curl -s http://ifconfig.me)

# dnsmasq
apt-get install dnsmasq -y
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/dnsmasq.conf -O /etc/dnsmasq.conf
sed '/netflix.com/d' /etc/dnsmasq.conf && echo "address=/netflix.com/${IP}" >> /etc/dnsmasq.conf
sed '/nflxvideo.net/d' /etc/dnsmasq.conf && echo "address=/nflxvideo.net/${IP}" >> /etc/dnsmasq.conf

# sniproxy
apt-get install sniproxy -y
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/sniproxy.conf -O /etc/sniproxy.conf
sed -i "s/^#DAEMON_ARGS/DAEMON_ARGS/g" /etc/default/sniproxy

# nginx
curl -s http://nginx.org/keys/nginx_signing.key | apt-key add -
cat > /etc/apt/sources.list.d/nginx.list << EOF
deb http://nginx.org/packages/$(. /etc/os-release; echo "$ID")/ $(lsb_release -cs) nginx
deb-src http://nginx.org/packages/$(. /etc/os-release; echo "$ID")/ $(lsb_release -cs) nginx
EOF
apt-get update
apt-get install nginx=1.16.* -y
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/nginx.conf -O /etc/nginx/nginx.conf
sed -i "s/xxx.xxx.xxx.xxx/${Client}/g" /etc/nginx/nginx.conf
rm -rf /etc/nginx/conf.d/*

# systemd
systemctl restart sniproxy dnsmasq nginx
systemctl enable sniproxy dnsmasq nginx

echo ""
echo "Please login v2ray server and run command to check:"
echo "  dig netflix.com ${IP}"