#yum install zlib libcurl libcrypto rsync
cd $HOME/download
wget http://kernel.org/pub/software/scm/git/git-1.7.5.tar.bz2
tar -jxvf git-1.7.5.tar.bz2
cd git-1.7.5
./configure --prefix=/usr/local
make
make install
