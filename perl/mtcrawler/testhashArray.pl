use Data::Dumper;
my $content=();
my $name='hello';
$content->{$name}=[] if (!defined $content->{$name}) ;    
my @data=@$content->{$name};
push @data,'world';
push @data,'girl';

print Dumper $content;
