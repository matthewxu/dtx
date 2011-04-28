use bs;
use FileHandle;
my $HTTPSHOST = 'http://www.google.com';
my $firsturl  = $HTTPSHOST;
my $url = $HTTPSHOST."/prdhp?hl=zh-cn&tab=ff";
$url='http://go.xungou.com/key-mbphmlnflapm.html';
my $b=new bs();

$b->seturl($url);
my $s=$b->getReXMLString();


#print $s;
my $file=$b->savecontent($url,$s);
my $fh=new FileHandle();
$fh->open("> $file");
print $fh $s;
close $fh;
print $file;
