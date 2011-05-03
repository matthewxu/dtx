#!/usr/bin/perl
package bs;
#browse
$version=1.0;

use strict 'vars';
use warnings;
no warnings qw(uninitialized numeric);
use HTML::DOM;
use IO::Handle;
use Getopt::Long;
use Data::Dumper;
use LWP::UserAgent;
use LWP::ConnCache;
use HTTP::Cookies;
use HTTP::Response;
use HTML::Form;
use JSON;
use Sys::Hostname;	
use HTML::TreeBuilder;
use cf;
use fo;
use Digest::MD5 qw(md5 md5_hex md5_base64);
my $cookiefile='cookiefile';

my $ua = LWP::UserAgent->new;

my $fo=new fo();
sub new{
	my ($class, %args) = @_;
	my $self  = bless {}, $class;	
	my $cf=new cf(%args);
	$self->{cf}=$cf;
	my $cookies = new HTTP::Cookies(file=>$cookiefile,autosave=>1,);
	my $lwpconncache = $ua->conn_cache(LWP::ConnCache->new());
	$ua->conn_cache->total_capacity(undef);
	$ua->no_proxy();
	$ua->agent('Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-CN; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3');
	$ua->cookie_jar($cookies);
	$ua->timeout(300);
	$ua->requests_redirectable (['GET', 'HEAD', 'POST']);
	#print "cookie : ".$cookies->as_string."\n";
	#$ua->default_headers('Accept'=>'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
	#$ua->default_headers('Accept-Language'=>'en');
	#$ua->default_headers('Accept-Encoding'=>'gzip,deflate');
	#$ua->default_headers('Accept-Charset'=>'utf-8');
	#$ua->default_headers('Keep-Alive'=>115);
	#$ua->default_headers('Connection'=>'keep-alive');	
	#$ua->local_address("127.0.0.1");
	$ua->max_redirect(20);
	$ua->show_progress(1);
	$self->{ua}=$ua;
return $self;
}

sub download{
	my($self,$url)=@_;
	unless($url){
		return '<no>no url</no>';	
	}
	my $request = HTTP::Request->new('GET', $url);
	my $urlmd5=md5_hex($url);		
	my $crawlerdatafold=$self->{cf}->{'crawlerdata'};	
	my $crawlerdatafoldtmp=$self->{cf}->{'crawlerdatatmp'};
	
	print 	$crawlerdatafold."\n";
	print 	$crawlerdatafoldtmp."\n";
	my $response = $ua->request($request, "$crawlerdatafoldtmp/$urlmd5"); 
	my $realname=$response->filename || "$urlmd5";
	$fo->movefile("$crawlerdatafoldtmp/$urlmd5","$crawlerdatafold/$realname");
	# 	my $response = $ua->request($request, \&saveCallBack, 4096);

return "$crawlerdatafold/$realname";	
}

sub post{
	my($self, $posturl, $params,$debug) = @_;
	my $response = $self->{ua}->post($posturl, $params,);	
	print "INFO: Login Result".$response->status_line()."\n";
#	print Dumper $response if $debug;
	if ($response->status_line() !~ /^200 OK$/i){
		print "ERROR: ".$response->status_line().", please contact technical support...\n";
	} else {
	}
	return $response->content();
}

sub getReString{

	my($self,$url)=@_;
	if($url){
#		$logouturl=$url;
		$self->{url}=$url;
	}
	unless($self->{url}){
		return '<no>no url</no>';	
	}
	my $response = $self->{ua}->get($self->{url});
	my $string=$response->content();
return $string; 
}

sub getCachedFile{
		my($self,$url)=@_;
		my $crawlerdatafold=$self->{cf}->{'crawlerdata'};
		my $urlmd5=md5_hex($url);			
		return "$crawlerdatafold/$urlmd5" if(-e "$crawlerdatafold/$urlmd5");
		return $self->savecontent($url,$self->getReString($url));
}

sub getFilePath{
		my($self,$url)=@_;
		my $crawlerdatafold=$self->{cf}->{'crawlerdata'};
		my $urlmd5=md5_hex($url);			
		return "$crawlerdatafold/$urlmd5";
}


sub getReXMLString{

	my($self,$url)=@_;
	if($url){
#		$logouturl=$url;
		$self->{url}=$url;
	}
	unless($self->{url}){
		return '<no>no url</no>';
	}	
	my $string=$self->getReString($url);
	my $tree = new HTML::TreeBuilder();
	$string=$tree->parse_content($string)->as_XML();
return $string; 
}

sub savecontent{
	my ($self,$url,$content)=@_;
	if($url){
#		$logouturl=$url;
		$self->{url}=$url;
	}
	unless($self->{url}){
		return '<no>no url</no>';
	}
	my $crawlerdatafold=$self->{cf}->{'crawlerdata'};
	my $urlmd5=md5_hex($url);			
#	if(system("echo '$content' > $crawlerdatafold/$urlmd5")){
#		die "echo  > $crawlerdatafold/$urlmd5 fail \n";
#	}
	$fo->appendStringToFile("$crawlerdatafold/$urlmd5",$content,1);
return "$crawlerdatafold/$urlmd5";

}

sub seturl{
	my($self,$url)=@_;
	$url=~s/^http:\/\///i;
	if($url=~/\//){
		if($url=~/(.*?)\//i){
			$self->{host}=$1;
		}else{
			$self->{host}=$url;
		}
	}
	$self->{url}="http://".$url;
return 1;
}
sub geturl{
my($self)=@_;
	return $self->{url};

}

sub fixurl
{
	my($self,$url,$hostname)=@_;
	if($url=~/^http:\/\//i){
		return $url;
	}
	unless($hostname){
		$hostname=$self->{host};
	}
	if( $url=~/^www\./i){
		return "http://".$url;
	}else{
		return "http://".$hostname.$url;
	}
}
1;
