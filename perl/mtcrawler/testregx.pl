my $string='http://www.smarter.com.cn/computers-553/category/stdcomponent-554/';

#my $regx='\/\/.*smarter.*\/computers';
#
#if($string=~/$regx/){
#	print "success: $regex :::::: $string \n";
#
#}else{
#
#	print "fail: $regex :::::: $string \n";
#}
#
#my $url='http://www.smarter.com.cn/computers-553/category/stdcomponent-554/';
#$url=~s/^http:\/\///i;
#
#if($url=~/\//){
#	if($url=~/(.*?)\//i){
#			print $1."\n";
#		}else{
#			print $url."\n";
#		}
#	}
#print $url."\n";
#print "---------------------------\n";
#	my @specialtag=('\\\\','\^','\$','\*','\.','\+','\?','\|','\/');
#	foreach my $tag(@specialtag){
#		print $tag."\n";
#		print $string."\n";
#		$string=~s/$tag/$tag/ig;
#	}
#print $string;
use Data::Dumper;
use rg;
my $st='[[^[[http://www.kkk.com{}/[[.*[[index.html[[$[[ [[';
my $ssst=rg->specialtag($st);
print  $ssst.":\n";


my @s=split /\[\[/,$st;
my $k=pop @s;
print ":".$k.":\n";
 
#
#my %sss=split /\[\[/,$st;
#
#print Dumper \%sss;
#my @list=%sss;
#my $kkkkkk=join('',@list);
#print  $kkkkkk;
#foreach my $s(@sss){
#	print $s,"\n";
#}
	




