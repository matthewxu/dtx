echo "mysql -uroot -p123456 test  < /home/mxu/installscript/adgroup_sd.sql "
echo "mysql -uroot -p123456 test  < /home/mxu/installscript/adgroup.sql "
mysql -uroot -p123456 test  < $1
