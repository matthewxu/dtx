#!/usr/bin/perl
package cm;
#content mapping
$version=1.0;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use FileHandle;
use Bloom::Filter;
use XML::XPath;
use XML::XPath::XMLParser;
use cf;
my $COUNT=10000000;
my $bfilter = Bloom::Filter->new( error_rate => 0.0000001, capacity => $COUNT );
my $cf=new cf();

sub new{
        my ($class, %args) = @_;
        my $self  = bless {}, $class;
	return $self
}

sub urlcheck{
#mapping for crawling or  abandon
	my($self,$url,@others)=@_;
	my $urlmd5=md5_hex($url);
	if($filter->check($urlmd5)){
		print $url," already handle before\n";
		return 0;
	}
return 1;
}

sub urlDone{
	my($self,$url,@others)=@_;
	my $urlmd5=md5_hex($url);
	$bfilter->add($urlmd5);
	$self->saveDoneUrl($url,$urlmd5);
	return 1;
}

sub digmapping{
#mapping for content to save
	my($self,$url,$file,@others)=@_;
	my $mp=$cf->getmpcf()->{'mp'};
	my $content=();
	foreach my $regx (keys %$mp){
	#loop url regx
		if($url=~/$regx/){
			my $xpaths=$mp->{$regx};
			foreach my $xpath (keys %$xpaths){
				my $type=$xpaths->{$xpath}->{type};
				my $name=$xpaths->{$xpath}->{name};
				my @data=();	
				if($type eq 'img'){
				#download and save path			

				}elsif($type eq 'text'){
				#save text
					my $xp = XML::XPath->new(filename => $file);
					my $nodeset = $xp->find($xpath); 
    					foreach my $node ($nodeset->get_nodelist) {
				    		print $node->getValue."\n";
						push @data, $node->getValue;
					}		
				}elsif($type eq 'nurl'){
				#nexturl: eg. pagination "products fenye 1,2,,", just crawl it, not save the name or others
										
				}elsif($type eq 'aurl'){
				#anotherurl: eg. computerpage=>dellpage save "computer=>dell dellpageurl"
					                                
                }elsif($type eq 'mtext'){
               	#how to handle array content 
				#eg.	one product ,many imgs,many merchants
                                
                                
                                
                }elsif($type eq 'texturl'){
                            
                                
                                
                                
                }
				$content->{$name}=\@data;
			}

		}
	}
	print Dumper $content;

	return $content;	
}


sub saveDoneUrl{
	my($self,$url,$key,@others)=@_;
        my $urltofile="$cf->getfilecf()->{'urltofile'}.$self->{batchid}";
	
        my $fh;
	if(defined $self->{doneurlhandle}) {
		$fh= $self->{doneurlhandle};
	}else{
	$fh=new FileHandle();
        $fh->open(">> $urltofile") || die "$urltofile fail\n";
	$fh->autoflush(1);       
	 $self->{doneurlhandle}=$fh;
	}
	print $fh "$key\t$url\n";
	
}
sub getDoneUrl{
        my($self,@others)=@_;
	if(defined $self->{bfilter}){
		return $bfilter;
	}        
        my $urltofile="$cf->getfilecf()->{'urltofile'}.$self->{batchid}";
        my $fh=new FileHandle();
        $fh->open($urltofile) || die "$urltofile fail\n";
	while(my $l=<$fh>){
		my($md5,$url)=split '\t',$l;
		$bfilter->add($md5);
		
	}	
	close $fh;
	$self->{bfilter}=$bfilter;
	return $bfilter;
} 


sub _destroy{
	my($self,@others)=@_;
	if(defined $self->{doneurlhandle}){
	close $self->{doneurlhandle};
	undef $self->{doneurlhandle};
	}
}
1;
