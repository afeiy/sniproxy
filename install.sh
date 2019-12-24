#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

[ $(id -u) != 0 ] && (echo "${red}Please run as root user!${plain}" && exit 1)
IP=$(curl -s http://ifconfig.me)

# dnsmasq
echo -e "${green}Install Dnsmasq...${plain}"
apt-get install dnsmasq -y
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/dnsmasq.conf -O /etc/dnsmasq.conf
sed -i '/netflix.com/d' /etc/dnsmasq.conf && echo -e "\naddress=/netflix.com/${IP}" >> /etc/dnsmasq.conf
sed -i '/nflxvideo.net/d' /etc/dnsmasq.conf && echo "address=/nflxvideo.net/${IP}" >> /etc/dnsmasq.conf
systemctl restart dnsmasq
lsof -i:5353 || (echo -e "${red}Install Dnsmasq exception...${plain}" && exit 1)


# sniproxy
echo -e "${green}Install SNI Proxy...${plain}"
apt-get install sniproxy -y
mkdir -p /var/log/sniproxy
wget https://raw.githubusercontent.com/buxiaomo/sniproxy/master/sniproxy.conf -O /etc/sniproxy.conf
sed -i "s/^#DAEMON_ARGS/DAEMON_ARGS/g" /etc/default/sniproxy
sed -i "s/^ENABLED.*/ENABLED=1/g" /etc/default/sniproxy
systemctl restart sniproxy
lsof -i:80 || (echo -e "${red}Install SNI Proxy exception...${plain}" && exit 1)
lsof -i:443  || (echo -e "${red}Install SNI Proxy exception...${plain}" && exit 1)

# nginx
echo -e "${green}Install Nginx...${plain}"
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
systemctl restart nginx
lsof -i:53  || (echo -e "${red}Install Nginx exception...${plain}" && exit 1)

# systemd
systemctl restart sniproxy dnsmasq nginx
systemctl enable sniproxy dnsmasq nginx

echo "Dnsmasq + SNI Proxy installed！

Change your DNS to ${IP} and you can watch Netflix."