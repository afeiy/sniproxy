#!/bin/bash
IP=$(curl -s http://ifconfig.me)

[ $(id -u) != 0 ] && (echo "Please run as root user!" && exit 1)
apt-get install sniproxy dnsmasq -y
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/dnsmasq.conf -O /etc/dnsmasq.conf
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/sniproxy.conf -O /etc/sniproxy.conf
cat >> /etc/sniproxy.conf << EOF
address=/netflix.com/${IP}
address=/nflxvideo.net/${IP}
EOF
curl -s http://nginx.org/keys/nginx_signing.key | apt-key add -
cat > /etc/apt/sources.list.d/nginx.list << EOF
deb http://nginx.org/packages/$(. /etc/os-release; echo "$ID")/ $(lsb_release -cs) nginx
deb-src http://nginx.org/packages/$(. /etc/os-release; echo "$ID")/ $(lsb_release -cs) nginx
EOF
apt-get update
apt-get install nginx=1.16.* -y
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/nginx.conf -O /etc/nginx/nginx.conf
sed -i "s/xxx.xxx.xxx.xxx/${Client}/g" /etc/nginx/nginx.conf
systemctl restart sniproxy dnsmasq nginx
systemctl enable sniproxy dnsmasq nginx

echo "please login v2ray server and run command to check:"
echo "dig netflix.com ${IP}"