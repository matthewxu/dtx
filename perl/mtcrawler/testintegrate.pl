####test all funtion###
use Getopt::Long;
#use Proc::Daemon;
use bs;
use cf;
use cm;
use fo;
use sm;
my $base='testdata';
my $config='config.mt.zol';
my $starturl='http://detail.zol.com.cn/subcategory.html';
my $daemon;
my $options = GetOptions (
			'base=s'		=> \$base,
			'starturl=s'	=>\$starturl,
			'config=s'		=> \$config,
			'daemon!'		=> \$daemon,
			);
#Proc::Daemon::Init() if $daemon;

my $log_file="log_".$$.".log";
if ($daemon) {
    open(STDOUT, ">>", $log_file) and open(STDERR, ">>", $log_file)
        or die "can not open log file: $log_file, err: $!";
}			
			
			
print "Input base:$base,config:$config\n";

my $args={'base'=>$base,'config'=>$config};
#print Dumper $args;
my $cm=cm->new(%$args);

#my $starturl='http://www.xungou.com/channel_electronics/';
my $content=$cm->digmapping($starturl,1)->{data};
foreach my $cc(@$content){
	print $cc->{cc}."\n";
#	while(my($k,$v)=each %$cc){
#		print "$k,$v\n";
#	}
}





print "___Finish__\n";
