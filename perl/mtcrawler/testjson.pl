use Data::Dumper;
use JSON qw/to_json from_json/;
my $jsontext='{"test":[{"city":"bj","size":16800,"pop":1600},{"city":"sh","size":6400,"pop":1800}]}
';

my $h = from_json( $jsontext );
print Dumper $h;

my $h=();

$h->{a}=11;
$h->{b}=12;
my $s=to_json($h);

print "================\n$s";