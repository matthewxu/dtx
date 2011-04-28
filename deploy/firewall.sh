#ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
#web
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
iptables  -A OUTPUT -p tcp --sport 9312 -j ACCEPT
#remove or comment following settings in iptables
#-A RH-Firewall-1-INPUT -j REJECT --reject-with icmp-host-prohibited
service iptables start 
