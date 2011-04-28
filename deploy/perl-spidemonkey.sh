cd $HOME/download
wget http://ftp.mozilla.org/pub/mozilla.org/js/older-packages/js-1.5-rc3a.tar.gz
wget http://search.cpan.org/CPAN/authors/id/T/TB/TBUSCH/JavaScript-SpiderMonkey-0.20.tar.gz
tar zxvf http://ftp.mozilla.org/pub/mozilla.org/js/older-packages/js-1.5-rc3a.tar.gz
tar zxvf http://search.cpan.org/CPAN/authors/id/T/TB/TBUSCH/JavaScript-SpiderMonkey-0.20.tar.gz
    cd js/src
    make -f Makefile.ref
cp ../js/src/Linux_All_DBG.OBJ/libjs.so /usr/local/lib/libjs.so 	
LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH 

    cd ../JavaScript-SpiderMonkey-2.00
    perl Makefile.PL
    make
	chcon -t texrel_shlib_t ../js/src/Linux_All_DBG.OBJ/libjs.so
	chcon -t texrel_shlib_t /usr/local/lib/libjs.so
    make test
    make install
