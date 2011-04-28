#prerequirement： install MozPrel, Firefox
#!/usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize::FireFox;
my $mech = WWW::Mechanize::FireFox->new( autoclose => 0,);
#$mech->get('http://www.163.com');
#sleep 3;
#$mech->get('http://www.sina.com.cn');
#sleep 3;
$mech->get('http://www.google.com.hk');
my $png = $mech->content_as_png();
  my $outfile='1.png';  
    open my $out, '>', $outfile
        or die "Couldn't create '$outfile': $!";
    binmode $out;
    print {$out} $png;
#    $mech->highlight_node(
#      $mech->selector('a'));
      
          print $_->{href}, " - ", $_->{innerHTML}, "\n"
      for $mech->selector('a');
      
    my $retries = 10;
    while ($retries-- and ! $mech->is_visible( xpath => "id('gb_51')")) {
          sleep 1;
    };
    die "Timeout" unless $retries;
    
    # Now the element exists
    $mech->click({xpath =>"id('gb_51')"});
#$mech->eval_in_page('alert("Hello FireFox")');
# my $mech = new WWW::Mechanize::Firefox;
# $mech->get_local('datei.html');
# $mech->eval_in_page("alert('Hello YAPC Europe');");
