#!/usr/bin/perl

package fo;
$VERSION = 0.1;

use strict;
use warnings;
no warnings qw(uninitialized numeric);
use Fcntl ':flock'; # import LOCK_* constants 

use Digest::MD5;
use Data::Dumper;
use FileHandle;
use Carp;
use File::Copy;
use Sys::Hostname;
use Time::HiRes qw(gettimeofday);
#use File::NFSLock;
use File::SharedNFSLock;
use Encode qw/encode decode from_to/; 
use HTML::Entities qw/encode_entities decode_entities encode_entities_numeric/;
$|++;
# ========================================================================================


sub new {
	my ($class,%args) = @_;
	my $self = bless {},$class;
	return $self;
} 

sub waitfile
{
	my ($self,$filename,$sleepsecond,$maxhour,$maxtimes,$ignorestatcheck,@args) = @_;

	$maxhour = 17 if(!$maxhour);
	$maxtimes = 240 if(!$maxtimes);
	$sleepsecond = 180 if(!$sleepsecond);
	
	my $b_exists = 0;
	my $b_changing = 1;
	
	my $times = 1;
	while(1)
	{
		
		$times++;
		return $times if($self->fileexists($filename,$ignorestatcheck));
		if($times > $maxtimes || SemDateTime->getSemCurrentHour() > $maxhour)
		{
			last;
		}
		
		print "$filename does not exists. We will try again in $sleepsecond seconds (has tried $times times)\n";
		sleep $sleepsecond;
	}

	print "$filename has failed. We have tried $maxtimes times (Or it is almost end of day) and still not there!\n";
	return 0;
}

sub openFile
{
	my ($self,$file,$locktype,$expiretime,$maxwaittime,$operatetype,@args) = @_;
	$self->lockfile($file,$locktype,$expiretime,$maxwaittime);
	$expiretime=600 unless($expiretime);
	$maxwaittime=600 unless($maxwaittime);
	$operatetype="read" unless($operatetype);
	$file=">>".$file if($operatetype eq 'append');
	$file=">".$file if($operatetype eq 'rewrite');
	
	my $fh=new FileHandle();
	$fh->open("$file") || die "cannot open $file \n";
	
	return $fh;
	
}

sub closeFile
{
	my ($self,$file,$fh,@args) = @_;
	$self->unlockfile($file);
	$fh->close();
}


sub copyfile
{
	my ($self,$from,$to,@args) = @_;
	$self->lockfile($to,'LOCK_EX',600,1000);
	print "cp -f $from $to ...";
	my $status = system("cp -f $from $to");
	$self->unlockfile($to);
	
	if($status > 0)
	{
		my $oSendMail = sm->new(
							'debug'=>$self->{"debug"},
						);

		$oSendMail->send_email(
			"subject" => "copy failed: cp -f $from $to!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
			"text" => "copy failed: cp -f $from $to, please manual copy the file!\n",
			"to" => 'matthewatmezi@gmail.com, matthewatmezi@gmail.com');
		die "die: copyfile failed: cp -f $from $to\n";
	}
	
	print "cp -f $from $to ...done!";
	return 1;
}

sub movefile{
	my ($self,$from,$to,@args) = @_;
	$self->lockfile($to,'LOCK_EX',600,1000);
	print "mv $from $to ...\n";
	my $status = system("mv $from $to");
	$self->unlockfile($to);
	
	if($status > 0)
	{
		my $oSendMail = sm->new(
							'debug'=>$self->{"debug"},
				);

		$oSendMail->send_email(subject => "move failed: mv $from $to!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
					 text => "move failed: mv $from $to, please manual move the file!\n",
					 to => 'matthewatmezi@gmail.com, matthewatmezi@gmail.com');
		die "die: movefile failed: mv $from $to\n";
	}
	
	print "done!\n";
	return 1;
}

sub appendfile{
	my ($self,$from,$to,$unlinkfrom,@args) = @_;
	print "cat $from >> $to...";
	$self->lockfile($to,'LOCK_EX',300,600);
	my $errmsg='';
	my $fhto = new FileHandle();
	$fhto->open(">> $to") or $errmsg.="Open file $to failed\n";
	my $fhfrom = new FileHandle();
	$fhfrom->open("$from") or $errmsg.="Open file $from failed\n";
	if(!$errmsg) {
		while (my $line=<$fhfrom>) {
			print $fhto $line;
		}
	}
	close $fhfrom if($fhfrom);
	close $fhto if($fhto);
	$self->unlockfile($to);
	
	if(!$errmsg) {
		unlink $from if($unlinkfrom);
	} else {
		print "cat failed for $from >> $to\n$errmsg";
		my $oSendMail = sm->new(
							'debug'=>$self->{"debug"},
				);

		$oSendMail->send_email(subject => "cat $from >> $to failed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
					 text => "cat $from >> $to failed, please manual cat the file!\n$errmsg",
					 to => 'matthewatmezi@gmail.com, matthewatmezi@gmail.com');
		exit 1;
	}
	print "done!\n";
}

sub appendStringToFile
{
	my ($self,$to,$str,$overwrite,$nolock,$encode,@args) = @_;
	print "echo string >> $to...\n";
	$self->lockfile($to,'LOCK_EX',300,600) if(!$nolock);
	my $errmsg='';
	unless($encode){
	$encode='utf8'
	}
	my $fhto = new FileHandle();
	if($overwrite)
	{
		open($fhto, ">:$encode", $to) or $errmsg.=$!.";Open file $to failed\n";;;
		#$fhto->open("> $to") or $errmsg.="Open file $to failed\n";
	}
	else
	{
		#$fhto->open(">> $to") or $errmsg.="Open file $to failed\n";
		open($fhto, ">>:$encode", $to) or $errmsg.=$!.";Open file $to failed\n";;
	}
	
	if(!$errmsg) {
		print $fhto $str;
	}
	close $fhto if($fhto);
	$self->unlockfile($to) if(!$nolock);
	
	if($errmsg) {
		print "echo failed for string >> $to\n$errmsg";
		die;
	}
	print "done!\n";
}


sub format_path {
	my ($self, $path, @args)=@_;
	
	my $lastchar=chop($path);
	while ($lastchar eq ' ') {
		$lastchar=chop($path);
	}
	$path =$path . $lastchar;
	$path =$path . '/' if ($lastchar ne '/');
	return $path;
}

sub check_path {
	my ($self, $path, $ifcreate, @args)=@_;
	my $success=1;
	my $i=1;
	my $j=length($path);
	
	while ($i<$j) {
		if (substr($path,$i,1) eq '/') {
			unless (-e substr($path,0,$i)) {
				if ($ifcreate) {
					mkdir substr($path,0,$i),+777;
					print "create ......" . substr($path,0,$i) . " \n";
					unless (-e substr($path,0,$i)) {
						print "directory failed: ". substr($path,0,$i)."\n";
						$success=0;
					}
					if (-e substr($path,0,$i) && !chmod(0777,substr($path,0,$i))) {
						print "Cannot change the mode of file ". substr($path,0,$i)."\n";
						$success=0;
					}
				} else {
					$success=0;
				}
			}
		} 
		$i++;
		last unless $success;
	}
	return $success;
}

sub getfilecounts {
	my ($self,$fileprefix,$indays,$fold,$startingdate,@args)=@_;
	my $filecount=0;
	my $dir=$fold;

	opendir DD, "$dir" or die "Could not opendir $dir: $!";
	my $filepatten='^' . $fileprefix . '_' ;
	while ($_=readdir(DD)) {
		print "*";
		next if ($_ eq "." or $_ eq "..");
		next if -d "$dir/$_";
		next if !(/$filepatten/);
		#next if !(/_(\d\d\d\d\d\d\d\d)\.dat$/);
		next if !(/_(\d{8})\.dat$/ || /_(\d{10})\.dat$/);
		next if($1 le $startingdate);
		$filecount++;
	}
	closedir DD;
	return $filecount;
}


sub filesize {
	my ($self,$filename,@args)=@_;
	return -1 unless (-e $filename);
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat $filename;
	return $size;
}

sub getFileLastModifiedDate {
	my ($self,$filename,$timezone,@args)=@_;
	return 0 unless (-e $filename);
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat $filename;

	my @tm = localtime($mtime);
#	my @tm =  $self->getsemtime($mtime,$timezone);
	my ($sday, $smon, $syear) = ($tm[3], $tm[4],$tm[5]);

	my $filedate= sprintf ("%04d%02d%02d", $syear+1900,  $smon+1, $sday);
#	print "$filename=>$filedate\n";
	return $filedate;
}


sub getfiletimestamp {
	my ($self,$filename,@args)=@_;
	return 0 unless (-e $filename);
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat $filename;
	return $mtime;
}


sub showfilelocks {
	my ($self,$fullfilename,@args)=@_;
	my $lockfile = $self->getlockfilepath($fullfilename);

	return unless(-e "$lockfile");
	
	my $fh=new FileHandle();
	$fh->open("$lockfile") || die "Open $lockfile failed!!!!!!!";
	flock($fh, LOCK_EX);
	while (my $line=<$fh>){
		$line = chomp($line);
		my ($hostin,$processin,$locktypein,$starttimein,$periodin) = split '\t',$line;
		my $timeremain = time-$periodin;
		print "$fullfilename\t$hostin\t$processin\t$locktypein\t$starttimein\t$periodin\t => $timeremain\n" if($timeremain>0);
	}
	flock($fh,LOCK_UN);
	close $fh;
	return;
}

sub getlockfilepath
{
	my ($self,$fullfilename,@args) = @_;
	my $path_parts = $self->pathinfo($fullfilename);
	my $filefold = $$path_parts{"dirname"} . "/";
	my $filename = $$path_parts{"basename"};
	my $lockfile = $filefold . "." . $filename . ".lock";
	return $lockfile;
}

sub pathinfo
{
	my ($self,$path,@args) = @_;
	my %path_parts = (
		'dirname' => '',
		'basename' => '',
		'extension' => '',
		'filename' => '',
	);
	
	if($path =~ /^([a-zA-Z0-9_]*)\@([^:]*):(.*)/)
	{
		$path_parts{"user"} = $1;
		$path_parts{"host"} = $2;
		$path = $path_parts{"path"} = $3;
	}
	
	if($path =~ /^(.*)\/([^\/]+)$/)
	{
		$path_parts{'dirname'} = $1;
		$path_parts{'basename'} = $2;
	}
	else
	{
		$path_parts{'dirname'} = ".";
		$path_parts{'basename'} = $path;
	}

	if($path_parts{'basename'} =~ /^(.*)\.([^\.]+)$/)
	{
		$path_parts{'filename'} = $1;
		$path_parts{'extension'} = $2;
	}
	else
	{
		$path_parts{'filename'} = $path_parts{'basename'};
	}
		
	return \%path_parts;
}

##lock file by temp file.
##lock type 
##		LOCK_SH 
##		LOCK_EX
##		
sub lockfile {
	my ($self,$fullfilename,$locktype,$expiretime,$maxwaittime,@args)=@_;
	print "locking file $fullfilename..........\n";	
	$locktype = 'BLOCKING' if(!$locktype);
	if($locktype eq 'LOCK_SH' || $locktype eq 'SHARED' || $locktype eq 'SH')
	{
		$locktype = 'SHARED';
	}
	else
	{
		$locktype = 'BLOCKING';
	}
	
	$expiretime = 60 if(!$expiretime);
	$maxwaittime = 300 if(!$maxwaittime);
	
	my $lock = File::SharedNFSLock->new(
		file				=> 			'c:/1.txt',#'$fullfilename',
#	    lock_type          => $locktype, #'BLOCKING|EXCLUSIVE|NONBLOCKING|SHARED
#		blocking_timeout   => $expiretime,
#	    stale_lock_timeout => $maxwaittime,
		timeout_acquire		=> $maxwaittime,
		timeout_stale		=> $expiretime,
	  );
	
	$self->{'lockedfile'}{$fullfilename} = $lock;
	return $lock;
}

sub unlockfile {
	my ($self,$fullfilename,@args)=@_;
	if(defined $self->{'lockedfile'}{$fullfilename} && $self->{'lockedfile'}{$fullfilename})
	{
		my $lock = $self->{'lockedfile'}{$fullfilename};
		$lock->unlock();
		delete $self->{'lockedfile'}{$fullfilename};
	}
	return 1;
}


sub loadFileContent
{
	my ($self,$filePath) = @_;
	my $alldata = "";
	return \$alldata if(! -e $filePath || -z $filePath);
	
	$self->lockfile($filePath,'LOCK_SH',300,600);
	my $fh = new FileHandle();
	$fh->open("$filePath") || die "die: Open file $filePath failed at $!\n";
	$alldata = do { local $/; <$fh>; };
	close $fh;
	$self->unlockfile($filePath);
	
	return \$alldata;
}

sub deleteTempFolder
{
	my ($self,$tempfolder) = @_;
	if(substr($tempfolder,0,1) eq "/" && $tempfolder =~ /temp/i)
	{
		return !system("rm -rf $tempfolder");
	}
	return 0;
}

sub getTempFolder
{
	my($self,$data_root,$writedate)=@_;
	return $self->{"tempfolder"} if(defined $self->{"tempfolder"} && $self->{"tempfolder"});
	$data_root = $self->{'dataroot'} if(!$data_root);
	$data_root = $self->format_path($data_root);
	my $count1=0;
	my $count2=0;
 create_folder:

    my $today = SemDateTime->getSemToday();
    $writedate = $today unless($writedate && $writedate=~/([0-9]{1,4})([0-9]{1,2})([0-9]{1,2})/);
	my $path=$data_root."temp/$writedate/";
    my $host = hostname(); 
	my($name,$aliases,$type,$len,@thisaddr)=gethostbyname($host); 
#    my $ip;
#    foreach(@thisaddr) 
#    { 
#      $ip=inet_ntoa($_); 
#    }
	my $pID=$$;
	my ($start_second, $microseconds) = gettimeofday();
	$microseconds = $start_second * 1000000 + $microseconds;
	my $randomInt =  int(rand(2147483647));
	$path=$path.$host."_".$pID."_".$microseconds."_".$randomInt."/";
	print "start to create temp folds on $path\n";
	if($self->check_path($path,0))
	{	$count1++;
		die "die at $1: create temp fold: $path \n" if($count1>3);
		goto create_folder;
	}
	else
	{	
		$count2++;
		die "die at $1: create temp fold: $path \n" if($count2>3);
		goto create_folder if(!$self->check_path($path,1));
	}

	print "we get tempfolder here: $path\n" if($self->{"debug"});
	$self->{"tempfolder"} = $path;
	return $path;
}




sub fileexists
{
	my ($self,$filename,$ignorestatcheck) = @_;
	my $lsinfo = $self->lsinfo($filename);
	return 0 if(! defined $$lsinfo{"filename"});
	return 1 if($ignorestatcheck);
	print "fileexists: checking $filename stat info...\n";
	sleep 10;
	my $lsinfo_2 = $self->lsinfo($filename);
	return 1 if($$lsinfo_2{"time"} eq $$lsinfo{"time"} && $$lsinfo_2{"size"} eq $$lsinfo{"size"});
	return 0;
}

sub lsinfo
{
	my ($self,$filename) = @_;
	#ssh wei@192.168.10.164 'ls -l aaasfsdf'
	my $pathinfo = $self->pathinfo($filename);
	#die "die: r_pathinfo failed: $filename\n" if(!defined $$pathinfo{"user"});
	my $cmd;
	
	if(defined $$pathinfo{"user"} && $$pathinfo{"user"})
	{
		$cmd = "ssh " . $$pathinfo{"user"} . "\@" . $$pathinfo{"host"} . " 'ls -H --full-time " . $$pathinfo{"path"} . " 2>&1'";
	}
	else
	{
		$cmd = "ls -H --full-time " . $filename . " 2>&1";
	}
	
	print "executing: $cmd\n";
	#my $cmdresult = '-rw-r--r-- 1 izhao wheel   2319 2009-09-21 02:11:37.148843000 +0000 advinioperation.pl';
	#-bash-3.2$ ls --full-time
	#total 664
	#drwxr-xr-x 3 izhao wheel   4096 2009-09-29 07:15:35.888504000 +0000 Crypt
	#-rw-r--r-- 1 izhao wheel   2319 2009-09-21 02:11:37.148843000 +0000 advinioperation.pl
	#rw-r--r-- 1 izhao wheel  19104 2009-10-13 09:52:59.132969000 +0000 advprocessrevcost.pl
	#-rw-r--r-- 1 izhao wheel   3030 2009-10-13 09:52:57.949049000 +0000 advputbidding.pl
	#	result
	#	$VAR1 = {
	#          'group' => 'wheel',
	#          'filename' => 'advinioperation.pl',
	#          'timezone' => '+0000',
	#          'time' => '2009-09-21 02:11:37.148843000',
	#          'mode' => '-rw-r--r',
	#          'user' => 'izhao',
	#          'size' => '2319'
	#        };
	
	
	my $cmdresult = `$cmd`;
	
	my $infos = {};
	if($cmdresult =~ /^(-[rwx-]{9})\W+(\d+)\W+([^ ]+)\W+([^ ]+)\W+([^ ]+)\W+(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+)[ ]*([^ ]+)[ ]*(.*)/)
	{
		$$infos{"mode"} = $1;
		$$infos{"user"} = $3;
		$$infos{"group"} = $4;
		$$infos{"size"} = $5;
		$$infos{"time"} = $6;
		$$infos{"timezone"} = $7;
		$$infos{"filename"} = $8;
	}
	elsif($cmdresult =~ /No such file or directory/i)
	{
		$$infos{"error"} = $cmdresult;
	}
	else
	{
		die("die: something is wrong here: $cmdresult\n");
	}
	return $infos;
}


sub filemd5{
	my ($self,$filename,@args) = @_;
	open(FILE, $filename) or die "Can't open '$filename': $!";
	binmode(FILE);
	my $md5 = Digest::MD5->new;
	while (<FILE>){
		$md5->add($_);
	}
	close (FILE);
	#print $md5->b64digest(), " $filename\n";
	return $md5->b64digest();
}

#



1;
__END__

