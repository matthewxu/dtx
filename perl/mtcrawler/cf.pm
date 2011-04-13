package cf;
#config
use fo;
my $fo=new fo();
sub new{
        my ($class, %args) = @_;
        my $self  = bless {}, $class;
		$self->{base}=$args->{'base'} || '/home/mxu/data';
		$self->{config}=$args->{'config'} || $self->{base}.'/config.mt';
return $self;
}
sub getfilecf{
	my($self,@others)=@_;
	$self->{urltofile}=$self->{base}.'/urltofile.mt';	
	$self->{crawlerdata}=$self->{base}.'/crawlerdata';
	$self->{crawlerdatatmp}=$self->{base}.'/crawlerdatatmp';
	$fo->check_path($self->{urltofile},1);
	$fo->check_path($self->{crawlerdata},1);
	$fo->check_path($self->{crawlerdatatmp},1);
	return $self;
}

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
                        my($regx,$xpath,$pagetype)=split '\t', $l;
         				my $xpathhash = from_json( $xpath, { utf8  => 1 } );               
						$self->{mpv2}->{$regx}->{xpath}=$xpathhash;
						$self->{mpv2}->{$regx}->{pagetype}=$pagetype;
                }
                close $fh;
        }
	return $self;
}
1;
