my $string='http://www.smarter.com.cn/computers-553/category/stdcomponent-554/';

my $regx='\/\/.*smarter.*\/computers';

if($string=~/$regx/){
	print "success: $regex :::::: $string \n";

}else{

	print "fail: $regex :::::: $string \n";
}

my $url='http://www.smarter.com.cn/computers-553/category/stdcomponent-554/';
$url=~s/^http:\/\///i;

if($url=~/\//){
	if($url=~/(.*?)\//i){
			print $1."\n";
		}else{
			print $url."\n";
		}
	}
print $url."\n";
