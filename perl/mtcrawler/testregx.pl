my $string='http://www.smarter.com.cn/computers-553/category/stdcomponent-554/';

my $regx='\/\/.*smarter.*\/computers';

if($string=~/$regx/){
	print "success: $regex :::::: $string \n";

}else{

	print "fail: $regex :::::: $string \n";
}
