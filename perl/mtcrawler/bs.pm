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
my $cf=new cf();
my $fo=new fo();
sub new{
	my ($class, %args) = @_;
	my $self  = bless {}, $class;	
	
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

sub getReString{

	my($self,$url)=@_;
	if($url){
#		$logouturl=$url;
		$self->{url}=$url;
	}
	unless($self->{url}){
		return '<no>no url</no>';	
	}
	my $response = $ua->get($self->{url});
	my $string=$response->content();
return $string; 
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
	my $crawlerdatafold=$cf->getfilecf()->{'crawlerdata'};
	my $urlmd5=md5_hex($url);			
	$fo->check_path("$crawlerdatafold/$urlmd5",1);
#	if(system("echo '$content' > $crawlerdatafold/$urlmd5")){
#		die "echo  > $crawlerdatafold/$urlmd5 fail \n";
#	}
	$fo->appendStringToFile("$crawlerdatafold/$urlmd5",$content,1);
return 1;

}

sub seturl{
	my($self,$url)=@_;
	$self->{url}=$url;
return 1;
}
sub geturl{

my($self)=@_;
return $self->{url};

}
1;
