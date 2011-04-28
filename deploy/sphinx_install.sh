cd $HOME/download
wget http://www.coreseek.cn/uploads/csft/3.2/coreseek-3.2.14.tar.gz
tar xzvf coreseek-3.2.14.tar.gz
cd coreseek-3.2.14
cd mmseg-3.2.14
./bootstrap    #输出的warning信息可以忽略，如果出现error则需要解决
./configure --prefix=/usr/local/mmseg3
make && make install
cd ..
cd csft-3.2.14
sh buildconf.sh
./configure --prefix=/usr/local/coreseek  --without-unixodbc --with-mmseg --with-mmseg-includes=/usr/local/mmseg3/include/mmseg/ --with-mmseg-libs=/usr/local/mmseg3/lib/ --with-mysql 
make && make install
cd ..
#test
#cd testpack
#cat var/test/test.xml    #此时应该正确显示中文
#/usr/local/mmseg3/bin/mmseg -d /usr/local/mmseg3/etc var/test/test.xml
#/usr/local/coreseek/bin/indexer -c etc/csft.conf --all
#/usr/local/coreseek/bin/search -c etc/csft.conf 网络搜索

