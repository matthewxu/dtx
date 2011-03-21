
use cm;
my $logouturl='http://www.smarter.com.cn/computers-553/category/stdcomponent-554/';
#my $file='t.t';

my $file='/home/mxu/data/crawlerdata/dd0e346a04c1bfdaac2572a3b0abf2c9';
my $cm=new cm();
my $content=$cm->digmapping($logouturl,$file);

foreach my $name(keys %$content){
	my $data=$content->{$name};
	print scalar(@$data)."\n";
	foreach (@$data){
	
		print $name,"\t",$_,"\n";
	}
}
