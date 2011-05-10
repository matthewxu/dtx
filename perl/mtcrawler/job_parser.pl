####
use Getopt::Long;
#use Proc::Daemon;
use bs;
use cf;
use cm;
use fo;
use sm;
use File::Copy;
use Bloom::Filter;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Bloom::Filter;
my $COUNT=1000000;
my $bfilter = Bloom::Filter->new( error_rate => 0.0000001, capacity => $COUNT );
my $base='testdata';
my $config='config.mt.zol.2';
my $starturl='http://detail.zol.com.cn/subcategory.html';
my $daemon;
my $forcerefresh=0;
my $index=0;
my $batchid='';
my $theme='data_';
my $options = GetOptions (
			'base=s'		=> \$base,
			'starturl=s'	=>\$starturl,
			'index=s'		=>\$index,
			'config=s'		=> \$config,
			'theme=s'		=> \$theme,
			'forcerefresh=s'		=> \$forcerefresh,
			'daemon!'		=> \$daemon,
			'batchid=s'		=>\$batchid,
			);

my $log_file="log_".$$.".log";
if ($daemon) {
    open(STDOUT, ">>", $log_file) and open(STDERR, ">>", $log_file)
        or die "can not open log file: $log_file, err: $!";
}			
#if(-e "C:/orgnizer/project/workspace-market/doc/perl/mtcrawler/result/next.url"){
#	die "C:/orgnizer/project/workspace-market/doc/perl/mtcrawler/result/next.url";
#}
my $args={'base'=>$base,'config'=>$config};			
my $cf= cf->new(%$args);			
print "Input base:$base,config:$config\n";
my $sameurlfile=$cf->{'resultdata'}."/same.url.txt".$batchid;
my $nexturlfile=$cf->{'resultdata'}."/next.url.txt".$batchid;
unlink $sameurlfile if(-e $sameurlfile);
unlink $nexturlfile if(-e $nexturlfile);
print "processing url:$index\t$starturl\n";
my $donefile=$cf->{'base'}."/done.txt".$batchid;

my $fhdone=new FileHandle();
$fhdone->open(">$donefile") || die "open $donefile fail\n";
system("perl parser.pl --starturl=$starturl --index=$index");
$bfilter->add(md5_hex($starturl));
print $fhdone "$starturl\t$index\t1\n";

my @tmpurls=();
push @urls,$starturl;
#loop start
loop:
#check tocrawler(same) list

if(-e $sameurlfile){
	#read tmp tocrawler list by sort
	my @urls=();
	my $fhsame=new FileHandle();
	$fhsame->open("$sameurlfile") || die "open $sameurlfile fail\n";
	#parser each url
	while(my $l=<$fhsame>){
		chomp($l);
		my ($newurl,$newindex)=split /\t/,$l;	
		push @urls,"$newurl\t$newindex";
	}
	close $fhsame;
	#rm file
#	move($sameurlfile,"$sameurlfile.done");	
	unlink($sameurlfile);
	
	print "now we need to process sameurls>>>>>>>>>>>: ".scalar(@urls)." urls \n";
	my $i=0;
	foreach my $todourl(sort{$a cmp $b} @urls){
		my ($newurl,$newindex,$status)=split /\t/,$todourl;
		if($bfilter->check(md5_hex($newurl))){
			print "next, dup url $starturl\n";
			next;
		}
		print $i++," cmd: perl parser.pl --starturl=$newurl --index=$newindex\n";
		system("perl parser.pl --starturl=$newurl --index=$newindex");
		print $fhdone "$newurl\t$newindex\t1\n";
		$bfilter->add(md5_hex($newurl));
	}
	#end parser
}
#goto loop;
goto loop if(-e $sameurlfile);

looptwo:


print "nexturlfile:$nexturlfile\n ";
if(-e $nexturlfile){
	my @urls=();
	#read tmp tocrawler list by sort
	my $fhsame=new FileHandle();
	$fhsame->open("$nexturlfile") || die "open $nexturlfile fail\n";
	#parser each url
	while(my $l=<$fhsame>){
		chomp($l);
		my ($newurl,$newindex,$status)=split /\t/,$l;	
		push @urls,"$newurl\t$newindex\t$status";
	}
	close $fhsame;
	
	#rm file
#	move($nexturlfile,"$nexturlfile.done");
	unlink $nexturlfile;	
	print "now we need to process>>>>>>>>>>>>>: ".scalar(@urls)." urls \n";
	my $i=0;
	foreach my $todourl(sort{$a cmp $b} @urls){
		my ($newurl,$newindex,$status)=split /\t/,$todourl;
		if($bfilter->check(md5_hex($newurl))){
			print "next, dup url $starturl\n";
			next;
		}
		print $i++," cmd:perl parser.pl --starturl=$newurl --index=$newindex\n";
		system("perl parser.pl --starturl=$newurl --index=$newindex");
		print $fhdone "$newurl\t$newindex\t1\n";
		$bfilter->add(md5_hex($newurl));
	}

	#end parser
}
#goto loop;
goto loop if(-e $sameurlfile);
goto looptwo if(-e $nexturlfile);
close $fhdone;

print "now we process data list..............\n";
my $cmd="perl combine.pl --config=$config --base=$base";
print $cmd."\n";
system($cmd);
print "___Finish__\n";
