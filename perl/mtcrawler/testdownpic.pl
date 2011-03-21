#!/usr/bin/perl
use strict;
use warnings;
#use Encode ;
use Data::Dumper;
use LWP::UserAgent;
use HTML::TokeParser;
use LWP::Simple ;




  my $ua = LWP::UserAgent->new;
my $request = HTTP::Request->new('GET', 'http://files.smarter.com.cn/images/new20/logo.gif?62');
#my  $response = $ua->request($request, '1.png'); 
#print $response->filename ."\n";
#my $r=$request->uri;
#print $r->path."\n";
#print $r->host."\n";
#print $r->path_query."\n";

#print local_address
#$response = $ua->request($request);
#   $response = $ua->request($request,$file);
  my  $response = $ua->request($request,\&callback,10240);

  
  
  sub callback {
        my ($data,$resp,$size) = @_;
        my $message=$resp->message(  );
        print Dumper $message;
        my $field=   $resp->headers();
        print Dumper $field;
         my $filename=   $resp->filename();
         print $filename."\n";
}

1;
