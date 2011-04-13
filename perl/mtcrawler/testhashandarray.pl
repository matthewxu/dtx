use Data::Dumper;
my $hasha=();
my @arraya=();

while(scalar(@arraya)<5){
	my $hashb=();
	$hashb->{scalar(@arraya)}=scalar(@arraya);
	push @arraya,$hashb; 
}

$hasha->{data}=\@arraya;


print Dumper $hasha;

foreach my $array(@arraya){
	$array->{test}='test';
	$array->{4}='test';
}
print Dumper $hasha; 