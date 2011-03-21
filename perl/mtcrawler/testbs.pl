use bs;
my $HTTPSHOST = 'http://www.google.com';
my $firsturl  = $HTTPSHOST;
my $url = $HTTPSHOST."/prdhp?hl=zh-cn&tab=ff";
$url='http://www.smarter.com.cn/computers-553/category/stdcomponent-554/';
my $b=new bs();

$b->seturl($url);
my $s=$b->getReXMLString();
#print $s;
$b->savecontent($url,$s);
