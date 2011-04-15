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
$cm->digmappingv2($starturl);





print "___Finish__\n";
