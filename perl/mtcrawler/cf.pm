package cf;
#config
use JSON qw/to_json from_json/;
use fo;
use Data::Dumper;
use rg;
my $fo=new fo();
sub new{
        my ($class, %args) = @_;
        my $self  = bless {}, $class;
		$self->{base}=$args{'base'} || '.';
		$self->{config}=$self->{base}."/".$args{'config'} || $self->{base}.'/config.mt';
		$self->{urltofile}=$self->{base}.'/urltofile.mt';	
		$self->{crawlerdata}=$self->{base}.'/crawlerdata';
		$self->{crawlerdownfile}=$self->{base}.'/crawlerdownfile';
		$self->{crawlerdatatmp}=$self->{base}.'/crawlerdatatmp';
		$fo->check_path($self->{urltofile},1);
		$fo->check_path($self->{crawlerdata}."/",1);
		$fo->check_path($self->{crawlerdownfile}."/",1);
		$fo->check_path($self->{crawlerdatatmp}."/",1);
		return $self;
}
#sub getfilecf{
#	my($self,@others)=@_;
#
#	return $self;
#}

sub getmpcf{
	my($self)=@_;        
    if($self->{config}){
                my $fh=new FileHandle();
                $fh->open($self->{config}) || die "open $self->{config} failed";
                while(my $l=<$fh>){
                        my($regx,$xpath,$type,$name)=split '\t', $l;

                        $self->{mp}->{$regx}->{$xpath}->{name}=$name;
                        $self->{mp}->{$regx}->{$xpath}->{type}=$type;
                }
                close $fh;
        }
	return $self;
}
sub getmpcfV2{
	my($self)=@_;        
    if($self->{config}){
                my $fh=new FileHandle();
                $fh->open($self->{config}) || die "open $self->{config} failed";
                while(my $l=<$fh>){
                		chomp($l);
                        my($regx,$xpath,$pagetype,$index)=split '\t', $l;
                        $regx=rg->specialtag($regx);
                        print "$regx\n"; 
         				my $xpathhash = from_json( $xpath, { utf8  => 1 } );               
						$self->{mpv2}->{$regx}->{xpath}=$xpathhash;
						$self->{mpv2}->{$regx}->{pagetype}=$pagetype;
						$self->{mpv2}->{$regx}->{'index'}=$index;
                }
                close $fh;
        }
	return $self;
}
1;
