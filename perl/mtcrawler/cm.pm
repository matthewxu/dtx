#!/usr/bin/perl
package cm;
#content mapping
$version=1.0;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use FileHandle;
use Bloom::Filter;
use XML::XPath;
use XML::XPath::XMLParser;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Data::Dumper;
use cf;
use bs;
my $COUNT=10000000;
my $bfilter = Bloom::Filter->new( error_rate => 0.0000001, capacity => $COUNT );
my $cf;
sub new{
        my ($class, %args) = @_;
        my $self  = bless {}, $class;
        $self->{base}=$args{'base'};
        $self->{config}=$args{'config'};
        print "cm init....\n";
		$cf=new cf(%args);
	return $self
}

sub getnewbrowser{
	my($self,@others)=@_;
	my $args={'base'=>"$self->{base}",'config'=>"$self->{config}"};

	print Dumper \$args; 
	my $b=new bs(%$args);
	return $b;	
}
sub setbrowser{
	my($self,$b,@others)=@_;
	unless($b){
		$b=$self->getnewbrowser();
	}
	$self->{bs}=$b;
	return 1;
}
sub getbrowser{
	my($self,$flag,@others)=@_;
	unless($flag){
		my $b=$self->getnewbrowser();
		return $b;
	}
	if(defined $self->{bs}){
		return $self->{bs};
	}else{
		my $b=$self->getnewbrowser();
		return $b;
	}
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
#					$self->{bs}->
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

#############################################################################
#content data meta
#cc:channelcat
#content->{ccurlmd5}->{ccname}=""
#content->{ccurlmd5}->{detailurlmd5}->	  				{name}=""
#														{price}=""
#														{img}=""
#														{desc}=""
#														{cc}=""
##############################################################################
#page has its type, channelcat;list;detail;
#config： url-regx pagetype	json-xpath
#we should flat it, channelcat-onething-details
#xpath json meta
##############################################################################

sub digmappingv2{
	#mapping for content to save
	my($self,$url,$file,$mycontent,@others)=@_;
	unless($file){
		my $b=$self->getbrowser();
		$b->seturl($url);
		$file=$b->getCachedFile($url);
	}
	my $mp=$cf->getmpcfV2()->{'mpv2'};
	my $content=();
	my @tocrawlerurl=();
	my @datalist=();
	foreach my $regx (keys %$mp){
	#loop url regx
		print "$regx,$url: \n";
		if($url=~/$regx/){
			print "match \n"; 
			#xpath instants
			my $xp = XML::XPath->new(filename => $file);
			#get root xpath
			my $xpaths=$mp->{$regx}->{xpath};
			#page type: channelcat,list,detail. if detail, just single thread(proc),other, fork new thread(proc)
			
			my $pagetype=$mp->{$regx}->{pagetype};

			#data list in one page
			##############First XPath json iterator##############
			foreach my $xpath (keys %$xpaths){
				print "first xpath $xpath\n";
				#get the first node list
				my $nodeset = $xp->find($xpath);
				#store one piece of onething data inhash		
					
				foreach my $node ($nodeset->get_nodelist) {
					#get 2 level xpath list
					my $xpathlist=$xpaths->{$xpath};
					my $nodestring= XML::XPath::XMLParser::as_string($node);
					print "subNode: $nodestring\n";
					my $xp2=XML::XPath->new($nodestring);
#					print Dumper $xp2;
#					die;
					my %datahash=();
										
					############seconde XPath json iterator##get same level content##################
					foreach $data(@$xpathlist){
						
						foreach my $xpath2(keys %$data){

							my $ntype=$data->{$xpath2};	
							my ($name,$type)=split '=',$ntype;
							print "xpath: $xpath2\n";
							my $nodeset2 = $xp2->find($xpath2);	
							foreach my $node2 ($nodeset2->get_nodelist) {
								my $nodevalue=$node2->getValue;
								print "$name\t$nodevalue\t$type\n";
								if($type eq 'img'){
									#download and save path			
									my $imgurl=$self->{'bs'}->fixurl($nodevalue);
									my $localpath=$self->getbrowser()->download($imgurl);
									$datahash{$name}=$localpath;														
								}elsif($type eq 'text'){
									#save text
									$datahash{$name}=$nodevalue;
								}elsif($type eq 'durl'){
									#detail url, this mean we are in list page.
									#todo callback or call another digmappings
									#need to do it right now or later in same piece of data
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
									$datahash{durl}=$fixedurl;					
								}elsif($type eq 'nurl'){
									#nexturl: eg. pagination "products fenye 1,2,,", just crawl it, not save the name or others
									# this mean we are in same page.
									#todo callback or call another digmappings
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
									push @tocrawlerurl,$fixedurl;#crawler it later
								}elsif($type eq 'aurl'){
									#anotherurl: eg. computerpage=>dellpage save "computer=>dell dellpageurl"
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
									$datahash{aurl}=$fixedurl;								                                
#				                }elsif($type eq 'attach'){
#					               	#how to attachments 
#				                                
#				                }elsif($type eq 'texturl'){
#				                            
				                }else{
				                	$datahash{$name}=$nodevalue;
				                }	
				                #in my case,it should be just one data.
				                last;										
							}
						} 
					}
					#################################
					print Dumper \%datahash;
					push @datalist, \%datahash;
				}
			}
			
		}else{
			print "not match \n";
		}
	}
	print Dumper @datalist;
	##### deal with need-to-be-handle url in datalist;
	my $urlmd5=md5_hex($url);
	$content->{url}=$url;	
	foreach my $piecedata(@datalist){
		if(defined $piecedata->{durl}){#detail url
			my $return=$self->digmappingv2($piecedata->{durl});
			my $returncontent =$return->{data};
			delete $piecedata->{durl};
			foreach my $onedata (@$returncontent){
				foreach my $d(keys %$onedata){
					$piecedata->{$d}=$onedata->{$d};
				}
			}
		}
		if(defined $piecedata->{aurl}){#another url
			my $return=$self->digmappingv2($piecedata->{aurl});
			my $returncontent =$return->{data};
			delete $piecedata->{aurl};

			foreach my $onedata (@$returncontent){
				$piecedata->{'cc'}.='=>'.$onedata->{'cc'};
				delete $onedata->{'cc'};
				foreach my $d(keys %$onedata){
					$piecedata->{$d}=$onedata->{$d};
				}
			}

		}
	}
	foreach my $nurl(@tocrawlerurl){#next page url
		my $return=$self->digmappingv2($piecedata->{nurl});
		my $returncontent =$return->{data};
		foreach my $onedata (@$returncontent){
			push @datalist,$onedata;
		}
		
	}
	$content->{data}=\@datalist;
	print Dumper $content;

	return $content;	
}


sub saveDoneUrl{
	my($self,$url,$key,@others)=@_;
        my $urltofile=$cf->getfilecf()->{'urltofile'}.$self->{batchid};
	
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
