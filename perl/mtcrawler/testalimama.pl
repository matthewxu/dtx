# testlogin alimama
use HTML::TreeBuilder::XPath;
use bs;
use FileHandle;
my $b=new bs();

$b->seturl("http://www.alimama.com/membersvc/member/login.htm");
my $s=$b->getReXMLString();
print $s."\n\n";

my $loginparam=();
$loginparam->{'TPL_username'}='matthew0816';
$loginparam->{'TPL_password'}='';
$loginparam->{'dologin'}='';
$loginparam->{'_tb_token_'}='558d74e87fe5f';
$loginparam->{'actionForStable'}='enable_post_user_action';
$loginparam->{'action'}='Authenticator';
$loginparam->{'TPL_redirect_url'}='http://login.taobao.com/member/taobaoke/login.htm?is_login=1';
$loginparam->{'event_submit_do_login'}='anything';
$loginparam->{'abtest'}='';
$loginparam->{'pstrong'}='';
$loginparam->{'from'}='tb';
$loginparam->{'web_type'}='taobaoke';
$loginparam->{'style'}='taobaoke';
$loginparam->{'gvfdcname'}='';
my $loginurl='http://login.taobao.com/member/taobaoke/login.htm';
my $s=$b->post($loginurl,$loginparam);
my $file=$b->savecontent($loginurl,$s);
print $file."\n\n";

my $shoplist='http://taoke.alimama.com/spreader/shop_list.htm';

$s=$b->getReXMLString($shoplist);
$file=$b->savecontent($shoplist,$s);
print $file."\n\n";


$shoplist='http://taoke.alimama.com/spreader/auction_list.htm?_tb_token_=58be9ee6be6e7&cat=23&q=&mid=0&advsort=advtaobao&isMallRedirect=';

$s=$b->getReString($shoplist);
$file=$b->savecontent($shoplist,$s);
#$file=$b->getFilePath($shoplist).".html";
print $file."\n\n";
#id('listview')/div[15]/div[2]/ul/li[2]/div/a/span
my $xpath1="id('listview')/div";
my $xpath2="div[2]/ul/li[2]/div/a/attribute::onclick";
#id('listview')/x:div[11]
my $xp = HTML::TreeBuilder::XPath->new();
$xp->parse_file($file);
my $nodeset = $xp->findnodes($xpath1);
#store one piece of onething data inhash	
my $getcodeurl;	
foreach my $node ($nodeset->get_nodelist) {
	my $nodevalue=$node->findvalue($xpath2);
#	print $nodevalue."\n";
	if($nodevalue=~/\((\d*.)\)/){
		$getcodeurl='http://taoke.alimama.com/spreader/gen_auction_code.htm?_tb_token_=58be9ee6be6e7&auction_id='.$1;
		$s=$b->getReString($getcodeurl);
		$file=$b->savecontent($getcodeurl,$s);

	}
}
print $getcodeurl."\n";				
#my $getcodeurl='http://taoke.alimama.com/spreader/gen_auction_code.htm?_tb_token_=58be9ee6be6e7&auction_id=9344820350';