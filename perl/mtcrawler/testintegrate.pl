####test all funtion###
use Getopt::Long;
use bs;
use cf;
use cm;
use fo;
use sm;
my $base='C:/orgnizer/project/workspace-market/doc/perl/mtcrawler/testdata';
my $config='config.mt';
my $options = GetOptions (
			'base=s'		=> \$base,
			'config=s'		=> \$config,
			);
print "Input base:$base,config:$config\n";

my $args={'base'=>$base,'config'=>$config};
#print Dumper $args;
my $cm=cm->new(%$args);
my $starturl='http://www.xungou.com/';
#my $starturl='http://www.xungou.com/channel_electronics/';
my $content=$cm->digmappingv2($starturl)->{data};
foreach my $cc(@$content){
	print $cc->{cc}."\n";
#	while(my($k,$v)=each %$cc){
#		print "$k,$v\n";
#	}
}





print "___Finish__\n";
