#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use HTML::Parser;
use JavaScript::SpiderMonkey;
use Data::Dumper;

my ($js_flag,$js,$eval,$js_text);
my $base = 'http://www.GIDEONonline.net';

my $js = JavaScript::SpiderMonkey->new();

$js->init();

# create all neccesary objects and functions
# for the javascript engine. These are the minimum
# for a working version, and are demanded by the infamous
# browser_check.js from www.webreference.com (which is
# what's behind SRC="js_lib/browser_check.js")
#
# how to set these automatically for an arbitrary
# javascript file is left as an excercise to the reader.

$js->property_by_path("document.location.href");
$js->property_by_path("window");
$js->property_by_path("navigator.userAgent");
$js->property_by_path("navigator.appVersion");
$js->function_set("toLowerCase", sub { return lc($_[0]); });
$js->function_set("javaEnabled", sub { undef });

# The OPs code slightly modified
{
    my $ua = new LWP::UserAgent();
    my $search_address = "$base/loginx.php?user=metalib";

    #creating the request object
    my $req = new HTTP::Request ('POST', $search_address);

    #sending the request
    my $res = $ua->request($req);
    if (!($res->is_success)){
        warn "Warning:".$res->message."\n";
    }

    my $response = $res->headers_as_string();
    my $response .= $res->content();
    my $p = HTML::Parser->new(
        default_h => [\&extract_js, "tag,attr,text"],
    );
    $p->parse($response);
    
    if($eval) {
        my $code = $js_text . "\n". $eval.";\n";
        my $rc = $js->eval( $code) if $eval;
        die $@ if $@;
    }
    my $url =  $js->property_get("document.location.href");
    if($url) {
        $response = $ua->get($base.'/'.$url);
        print $response->content if $response;
    } 
}

sub extract_js {
    my ($tag,$attr,$text) = @_;
    if($tag eq 'body') {
        $eval = $attr->{onload};
    } 
    $js_flag = 0 if $tag eq '/script';
    if($js_flag) {
        $js_text .= $text;
    }
    if ($tag eq 'script' || $tag eq 'javascript') {
        if ($attr->{src}) {
            my $ua = new LWP::UserAgent();
            my $res = $ua->get($base .'/'. $attr->{src});
            $js_text .= $res->content;
        }
        $js_flag++;
    } 
} 
