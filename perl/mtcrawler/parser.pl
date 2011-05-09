####test all funtion###
use Getopt::Long;
#use Proc::Daemon;
use bs;
use cf;
use cm;
use fo;
use sm;
use Bloom::Filter;
use Digest::MD5 qw(md5 md5_hex md5_base64);
#my $COUNT=1000000;
#my $bfilter = Bloom::Filter->new( error_rate => 0.0000001, capacity => $COUNT );
my $base='testdata';
my $config='config.mt.zol.2';
my $starturl='http://detail.zol.com.cn/subcategory.html';
my $daemon;
my $forcerefresh=0;
my $index;
my $options = GetOptions (
			'base=s'		=> \$base,
			'starturl=s'	=>\$starturl,
			'index=s'		=>\$index,
			'config=s'		=> \$config,
			'forcerefresh=s'		=> \$forcerefresh,
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
print "processing url:$index\t$starturl\n";
my $content=$cm->digmapping($starturl,$index);
#	if(defined $content->{surl}){
#		my $datalist=$content->{surl};
#		foreach my $data(@$datalist){
#			push @crawlerurls,$data;
#		}
#	}
#	
#	if(defined $content->{nurl}){
#		my $datalist=$content->{nurl};
#		foreach my $data(@$datalist){
#			push @crawlerurls,$data;
#		}
#	}




print "___Finish__\n";
