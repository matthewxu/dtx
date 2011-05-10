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
my $daemon;
my $forcerefresh=0;
my $index;
my $theme='data_';
my $options = GetOptions (
			'base=s'		=> \$base,
			'index=s'		=>\$index,
			'config=s'		=> \$config,
			'theme=s'		=>\$theme,
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
my $cf= cf->new(%$args);
#print Dumper $args;
my $cm=cm->new(%$args);
my $flist=fo->getfilelist($cf->{resultdata});
foreach my $file(@$flist){
	print $file."\n";
	
	my $filename=1;
	if($file=~/.*\/(.*?)\.txt/){
		$filename=$1;
	}
	
	$cm->DBDataResult($file,"$theme".$filename)
}
#my $content=$cm->digmapping($starturl,$index)s;





print "___Combine_Finish__\n";
