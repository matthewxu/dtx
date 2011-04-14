####test all funtion###
use Getopt::Long;
use bs;
use cf;
use cm;
use fo;
use sm;
my $root='C:\orgnizer\project\workspace-market\doc\perl\mtcrawler\testdata';
my $config='';
my $options = GetOptions (
			'root=s'		=> \$root,
			'config=s'		=> \$config,
			);
print "Input root:$root,config:$config\n";







print "___Finish__\n";
