use Data::Dumper;
my $t='test echo';
system("echo $t > t.t2");


my $c={'c'=>a,'a'=>'c'};

my $d=bless{},$c;

$d->{c}='c';

print Dumper $c;
print Dumper $d;