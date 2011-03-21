package cf;
#config

sub new{
        my ($class, %args) = @_;
        my $self  = bless {}, $class;
		$self->{base}='/home/mxu/data';
return $self;
}
sub getfilecf{
	my($self,@others)=@_;
	$self->{urltofile}=$self->{base}.'/urltofile.mt';	
	$self->{crawlerdata}=$self->{base}.'/crawlerdata';
	return $self;
}

sub getmpcf{
	my($self,%args)=@_;        
	$self->{config}=$args->{'config'} || $self->{base}.'/config.mt';
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
	my($self,%args)=@_;        
	$self->{config}=$args->{'config'} || $self->{base}.'/config.mt';
        if($self->{config}){
                my $fh=new FileHandle();
                $fh->open($self->{config}) || die "open $self->{config} failed";
                while(my $l=<$fh>){
                        my($regx,$xpath)=split '\t', $l;
         				my $xpathhash = from_json( $xpath, { utf8  => 1 } );               
						$self->{mpv2}->{$regx}->{xpath}=$xpathhash;
                }
                close $fh;
        }
	return $self;
}
1;
