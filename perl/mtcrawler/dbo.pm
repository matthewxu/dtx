#!/usr/bin/perl
package dbo;
$VERSION = 0.1;
#use strict;
#use warnings;
#no warnings qw(uninitialized numeric);
use Data::Dumper;
use DBI;

sub new
{
	my ($class,%args) = @_;
	my $self = bless {},$class;
	print "Initialize sembase.....\n";
	$self->{'systemvars'}	= $args{'systemvars'}	|| {};
	$self->{'dbname'} = $args{'dbname'} || 'test';
	$self->{'dbhost'} = $args{'dbhost'} || '127.0.0.1';
	$self->{'dbport'} = $args{'dbport'} || '3306';
	$self->{'dbuser'} = $args{'dbuser'} || 'root';
	$self->{'dbpass'} = $args{'dbpass'} || '123456';
	
	$self->{'dbraiseerr'} = 1;
	$self->{'dbraiseerr'} = $args{'dbraiseerr'} if defined $args{'dbraiseerr'};
	$self->{'dbprinterr'} = 1;
	$self->{'dbprinterr'} = $args{'dbprinterr'} if defined $args{'dbprinterr'};
	$self->{'dbreconnect'} = 1;
	$self->{'dbreconnect'} = $args{'dbreconnect'} if defined $args{'dbreconnect'};
	$self->{'dbuseresult'} = 0;
	$self->{'dbuseresult'} = $args{'dbuseresult'} if defined $args{'dbuseresult'};
	$self->{'dbautocommit'} = 0;
	$self->{'dbautocommit'} = $args{'dbautocommit'} if defined $args{'dbautocommit'};
	
	$self->{'dsn'} = "DBI:mysql:" . $self->{'dbname'} . ":" . $self->{'dbhost'} . ":" . $self->{'dbport'};
	$self->{'dbh'} = '';
	$self->{'dbhrefreshtime'} = 0;
	
	return $self;		
}

sub connect
{
	my ($self,$chartset,$attr,@args) = @_;
	unless($self->{'dbh'}){
		$self->{'dbh'} = DBI->connect($self->{'dsn'},$self->{'dbuser'},$self->{'dbpass'},{RaiseError => $self->{'dbraiseerr'}, PrintError=> $self->{'dbprinterr'}, mysql_auto_reconnect => $self->{'dbreconnect'}, mysql_use_result=> $self->{'dbuseresult'}, AutoCommit=>$self->{'dbautocommit'}});	

		if (defined $self->{'dbh'}){
			$self->{'dbhrefreshtime'} = time + 24*3600;
			$chartset='utf8' unless($chartset);
			eval {
				$self->{'dbh'}->do("SET NAMES '$chartset'"); #set db utf8
			}; 
			return undef if $@;
		} else {
			return undef;
		} 
	}
	return $self->{'dbh'};
}

sub insert
{
	my ($self,$sql,$datalist,@args) = @_;
	print $sql."\n";
	my $dbh=$self->checkdbconnection();	
	my $sth = $dbh->prepare("$sql");
	if (!$sth) {
		print "Error:" . $self->{'dbh'}->errstr . "\n";
		return 1;
	}
	eval {
		my $i=1;
		foreach my $a(@$datalist){
			my @set=split '\t',$a;
			$i=1;
			foreach(@set){
				$sth->bind_param($i++, $_);
			}
			
			if (!$sth->execute) {
				print "Error:" . $sth->errstr . "\n";
				return 2;
			}
		}
		$dbh->commit();
	};
	$self->closeDB();
	return 2 if $@;

	return 0;
}

sub createtable
{
	my ($self,$table,$title,@args) = @_;
#	CREATE TABLE table1 (
#  id int(5) NOT NULL auto_increment,
#  name varchar(40) default NULL,
#  phone varchar(40) default NULL,
#  email varchar(40) default NULL,
#  KEY id (id)
#)
	my $dbh=$self->checkdbconnection();	
	my $sql = "DROP TABLE IF EXISTS `$table`;";
	print $sql."\n";
	$dbh->do($sql);	
	 $sql="CREATE TABLE `$table` (";
	$sql .= "id int(10) NOT NULL auto_increment,";
	foreach (split /\t/, $title){
		$sql.="`".$_."` varchar(2000)  character set utf8 default NULL,";
	}
	$sql .="`parserTime` timestamp NULL         default CURRENT_TIMESTAMP,";
	$sql .= "KEY id (id) )";
#	$sql.="ENGINE=InnoDB DEFAULT CHARSET=utf8;";
	print $sql."\n";

	$dbh->do($sql);
	$self->closeDB();
	return 1;
}

sub executeSQL
{
	my ($self,$sql,@args) = @_;
	my $sth = $self->{'dbh'}->prepare("$sql");
	if (!$sth) {
		print "Error:" . $self->{'dbh'}->errstr . "\n";
		return 1;
	}
	eval {
		if (!$sth->execute) {
			print "Error:" . $sth->errstr . "\n";
			return 2;
		}
	};
	return 2 if $@;

	return 0;
}



sub getSelectHash
{
	my ($self,$sql,$key,@args) = @_;
	my $sth = $self->{'dbh'}->prepare("$sql");
	if (!$sth) {
		print "Error:" . $self->{'dbh'}->errstr . "\n";
	}
	
	eval{
		if (!$sth->execute) {
			print "Error:" . $sth->errstr . "\n";
		}
	};
	return undef if $@;
	
	my $names     = $sth->{'NAME'};
	my $numFields = $sth->{'NUM_OF_FIELDS'};
	my $namekeyhash={};
	if($key){
		for (my $i = 0 ; $i < $numFields ; $i++) {
			$$namekeyhash{$$names[$i]}=$i;
			print $$names[$i].",";
		}
		print "\n";
		my @keylist=split ',',$key;
		foreach my $k (@keylist){
			unless(defined $$namekeyhash{$k}){
				print "defined key:$k not exists in fileds!!!!!!!!!!!!!!! \n";
				return 1;
			}
		}
	}

	my $rowcount=0;
	my $selecthash={};
	while (my $ref = $sth->fetchrow_arrayref) {
		for (my $i = 0 ; $i < $numFields ; $i++) {
			my $rowkey='';
			if(defined $$namekeyhash{$$names[$i]}){
				my @keylist=split ',',$key;
				my @keyvalue=();
				foreach (@keylist){
					push @keyvalue,$$ref[$$namekeyhash{$_}];
				}
				$rowkey= join("\t",@keyvalue);
			}else{
				$rowkey=$rowcount;
			}
			$$selecthash{$rowkey}{$$names[$i]}=$$ref[$i];
		}
		$rowcount++;
	}

#	print CORE::dump $selecthash;
 	return $selecthash;
}


sub closeDB
{
	my ($self,@args) = @_;
	if($self->{'dbh'}){
		$self->{'dbh'}->disconnect;
		$self->{'dbh'} = '';
	}
}


sub setUser {
	my ($self, $user) = @_;
	
	$self->{'dbuser'} = $user;
}

sub setPassword {
	my ($self, $password) = @_;
	
	$self->{'dbpass'} = $password;
}

sub setHost {
	my ($self, $host) = @_;
	
	$self->{'dbhost'} = $host;
}

sub setDBName {
	my ($self, $dbname) = @_;
	
	$self->{'dbname'} = $dbname;
}
sub setDBPort {
	my ($self, $dbport) = @_;
	
	$self->{'dbport'} = $dbport;
}

sub setDSN {
	my ($self, $dsn) = @_;
	if($dsn){
		$self->{'dsn'} = $dsn;
	}else{
			$self->{'dsn'} = "DBI:mysql:" . $self->{'dbname'} . ":" . $self->{'dbhost'} . ":" . $self->{'dbport'};
	}
}

sub checkdbconnection {
	my ($self,$chartset,@args)=@_;

	my $ret = 0;
	eval {
		local $SIG{__DIE__}  = sub { return (0); };
		local $SIG{__WARN__} = sub { return (0); };
		$ret = $self->{'dbh'}->do('select 1');
	};
	
	
	if (!$ret || time gt $self->{'dbhrefreshtime'}) {
#		$self->{'dbh'}->disconnect;
		$self->{'dbh'} = DBI->connect($self->{'dsn'},$self->{'dbuser'},$self->{'dbpass'},{RaiseError => $self->{'dbraiseerr'}, PrintError=> $self->{'dbprinterr'}, mysql_auto_reconnect => $self->{'dbreconnect'}, mysql_use_result=> $self->{'dbuseresult'}, AutoCommit=>$self->{'dbautocommit'}});	
		#$self->{'dbh'}=DBI->connect();
		if (defined $self->{'dbh'}){
			$chartset='utf8' unless($chartset);
			eval {
				$self->{'dbh'}->do("SET NAMES '$chartset'");
			};
			return undef if $@;
			$self->{'dbhrefreshtime'} = time+24*3600;
			print "DB connection is refreshed: $ret || ". time . " gt ".$self->{'dbhrefreshtime'}."\n";
		} else {
			return undef;
		}
	}
	return $self->{'dbh'};
}

sub addslashes
{
	my ($self,$_str)=@_;
	$_str =~ s/(["'\\])/\\$1/g;
	return $_str;
}

1;

__END__