cd $HOME
wget http://linux.duke.edu/projects/yum/download/2.0/yum-2.0.7.tar.gz
tar -zxvf yum-2.0.7.tar.gz
cd yum-2.0.7
./configure 
make
make install
