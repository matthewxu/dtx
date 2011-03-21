use Bloom::Filter;

my $filter = Bloom::Filter->new( error_rate => 0.01, capacity => 1000000 );
open my $fh, "enormous_list_of_titles.txt" or die "Failed to open: $!";

while (<$fh>) {
	chomp;
	$filter->add( $_ );
}
close $fh;

lookup_song('ndex.htm');
lookup_song('index.htm');
lookup_song('catalog.htm');

sub lookup_song {
	my ( $title ) = @_;
	print " find $title \n" if $filter->check( $title );
	print " not find $title \n" unless $filter->check( $title );
}
