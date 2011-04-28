semanage port -l|grep http
semanage port -a -t http_port_t -p tcp 9312
semanage port -a -t http_port_t -p tcp 8888
echo "now httpd can bind 8888 port"
