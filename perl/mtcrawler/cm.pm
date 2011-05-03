#!/usr/bin/perl
package cm;
#content mapping
$version=1.0;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use FileHandle;
use Bloom::Filter;
use XML::XPath;
use XML::XPath::XMLParser;
use HTML::TreeBuilder::XPath;
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
	if($flag){
		my $b=$self->getnewbrowser();
		$self->{bs}=$b;
		return $b;
	}
	if(defined $self->{bs}){
		return $self->{bs};
	}else{
		my $b=$self->getnewbrowser();
		$self->{bs}=$b;
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
	my($self,$url,$regxindex,$mycontent,$file,@others)=@_;
#	if($regxindex==3){
#		print "$url,$regxindex\n";
#	}
	unless($file){
		my $b=$self->getbrowser();
		$b->seturl($url);
		$file=$b->getCachedFile($url);
	}
	my $mp=$cf->getmpcfV2()->{'mpv2'};
#print Dumper $mp;
	my $content=();
	my @tocrawlerurl=();
	my @datalist=();
	foreach my $regx (keys %$mp){
	#loop url regx
		print "$regx:: $mp->{$regx}->{'index'},$url:$file \n";
		if(($url=~/$regx/ &&(!$regxindex)) || ($regxindex && $regxindex eq $mp->{$regx}->{'index'} ) ) {
			print "match ======================== \n";
			my $pagetype=$mp->{$regx}->{pagetype};
			print "match $pagetype\n"; 
			#xpath instants
#			my $xp = XML::XPath->new(filename => $file);
			my $xp = HTML::TreeBuilder::XPath->new();
			$xp->parse_file($file);
			#get root xpath
			my $xpaths=$mp->{$regx}->{xpath};
			#page type: channelcat,list,detail. if detail, just single thread(proc),other, fork new thread(proc)
			
			my $pagetype=$mp->{$regx}->{pagetype};

			#data list in one page
			##############First XPath json iterator##############
			foreach my $xpath (keys %$xpaths){
				print "first xpath $xpath\n";
				#get the first node list
				my $nodeset = $xp->findnodes($xpath);
				#store one piece of onething data inhash		
				foreach my $node ($nodeset->get_nodelist) {
					#get 2 level xpath list
					my $xpathlist=$xpaths->{$xpath};
					print "subNode: $nodestring\n";
					my %datahash=();
										
					############seconde XPath json iterator##get same level content##################
					foreach $data(@$xpathlist){
						
						foreach my $xpath2(keys %$data){

							my $ntype=$data->{$xpath2};	
							my ($name,$type,$regxindex)=split '=',$ntype;
							print "xpath: $xpath2\n";
								my $nodevalue=$node->findvalue($xpath2);
								print "$name\t$nodevalue\t$type\n";
								if($type eq 'img'){
									#download and save path			
									my $bs=$self->getbrowser();
									$imgurl=$bs->fixurl($nodevalue);
									my $localpath=$bs->download($imgurl);
									$datahash{$name}=$localpath;														
								}elsif($type eq 'text'){
									#save text
									$datahash{$name}=$nodevalue;
								}elsif($type eq 'surl'){
									#sub cc url
									my  $bs=$self->getbrowser();
									$fixedurl=$bs->fixurl($nodevalue);
									$datahash{surl}=$fixedurl;
									$datahash{regxindex}=$regxindex;
									print "surl: $fixedurl\n";
								}elsif($type eq 'durl'){
									#detail url, this mean we are in list page.
									#todo callback or call another digmappings
									#need to do it right now or later in same piece of data
									my $bs=$self->getbrowser();
									my $fixedurl=$bs->fixurl($nodevalue);
									$datahash{durl}=$fixedurl;
									$datahash{regxindex}=$regxindex;
								}elsif($type eq 'lurl'){
									#list page url
									my $bs=$self->getbrowser();
									my $fixedurl=$bs->fixurl($nodevalue);
#									push @tocrawlerurl,$fixedurl;#crawler it later
									$datahash{lurl}=$fixedurl;	
									$datahash{regxindex}=$regxindex;
									print "lurl: $fixedurl\n";
								}
								elsif($type eq 'nurl'){
									#nexturl: eg. pagination "products fenye 1,2,,", just crawl it, not save the name or others
									# this mean we are in same page.
									#todo callback or call another digmappings
									my $bs=$self->getbrowser();
									my $fixedurl=$bs->fixurl($nodevalue);
									my %tmpurls=();
									$tmpurls{'nurl'}=$fixedurl;
									$tmpurls{'regxindex'}=$regxindex;
									print "nurl: $fixedurl\n";
									push @tocrawlerurl,\%tmpurls;#crawler it later
								}elsif($type eq 'aurl'){
									#anotherurl: eg. computerpage=>dellpage save "computer=>dell dellpageurl"
									my $bs=$self->getbrowser();
									my $fixedurl=$bs->fixurl($nodevalue);
									$datahash{aurl}=$fixedurl;	
									$datahash{regxindex}=$regxindex;
									print "aurl: $fixedurl\n";							                                
				                }else{
				                	$datahash{$name}=$nodevalue;
				                }	
						} 
					}
					#################################
					push @datalist, \%datahash;
				}
			}
			
		}else{
			print "not match \n";
		}
	}
	##### deal with need-to-be-handle url in datalist;
	my $urlmd5=md5_hex($url);
	$content->{url}=$url;	
	
	my @tmpdatalist=();
	foreach my $piecedata(@datalist){
		if(defined $piecedata->{surl}){#subchannel url
			print "surl:::: $piecedata->{surl}\n";
			my $return=$self->digmappingv2($piecedata->{surl});
			my $returncontent =$return->{data};
			my $cc=$piecedata->{cc};
			print "cc:$cc .................\n";
			delete $piecedata->{surl};
			delete $piecedata->{cc};
			foreach my $onedata (@$returncontent){
				my $subcc=$onedata->{cc};
				$onedata->{cc}=$cc."=>".$subcc;
				print $cc."=>".$subcc."\n" if($self->{debug});
				foreach my $d(keys %$piecedata){
					$onedata->{$d}=$piecedata->{$d};
				}
				my %savedata=%$onedata;
				push @tmpdatalist,\%savedata;
			}
		}
	}
	if(scalar(@tmpdatalist)>0){
		@datalist=@tmpdatalist;
	}



	foreach my $piecedata(@datalist){
		if(defined $piecedata->{aurl}){#another url
			print "aurl:::: $piecedata->{aurl},$piecedata->{regxindex}\n";
			my $return=$self->digmappingv2($piecedata->{aurl},$piecedata->{regxindex});
			my $returncontent =$return->{data};
			delete $piecedata->{aurl};
			delete $piecedata->{regxindex};
			foreach my $onedata (@$returncontent){
				if(defined $onedata->{'cc'}){
					$piecedata->{'cc'}.='=>'.$onedata->{'cc'};
				}
				delete $onedata->{'cc'};
				foreach my $d(keys %$onedata){
					$piecedata->{$d}=$onedata->{$d};	
				}
			}
		}
	}
	
	foreach my $nurls(@tocrawlerurl){#next page url
		print "nurl:::: $nurls->{nurl}\n";
		my $return=$self->digmappingv2($nurls->{nurl},$nurls->{regxindex});
		my $returncontent =$return->{data};
		foreach my $onedata (@$returncontent){
			push @datalist,$onedata;
		}
		
	}
	####durl:detail url, also the last url,Last Data set , Not store in Memory###
	#TODO####Store into DB or File#########
#	@tmpdatalist=();
	foreach my $piecedata(@datalist){
		if(defined $piecedata->{durl}){#subchannel url
			print "durl::::>>>>>>>>> $piecedata->{durl},$piecedata->{regxindex}\n";
			my $return=$self->digmappingv2($piecedata->{durl},$piecedata->{regxindex});
			print "durl.... $piecedata->{durl}\n";
			my $returncontent =$return->{data};
			delete $piecedata->{durl};
			delete $piecedata->{regxindex};
			print Dumper $returncontent;
			foreach my $onedata (@$returncontent){
				foreach my $d(keys %$piecedata){
					$onedata->{$d}=$piecedata->{$d};
				}
				my %savedata=%$onedata;
#				push @tmpdatalist,\%savedata;

				my	$cols=();
				if(defined $self->{cols}){
					$cols=$self->{cols};
				}
				my $linedata='detail::';
				foreach my $colname(sort {$a<=>$b} keys %savedata){
					if(defined $self->{cols}){
						unless(defined	$cols->{$colname}){
							die "defined unuint col $colname\n";
						}
					}else{
						$cols->{$colname}=1;
					}
					$linedata.="\t".$savedata{$colname};
				}
				$self->{cols}=	$cols;
				print $linedata."\n";
				
			}
			print Dumper $returncontent;
			die;
			delete $return->{data};
		}
	}
#	if(scalar(@tmpdatalist)>0){
#		@datalist=@tmpdatalist;
#		#######!!!!!!!!!!!!!!#####################
#		##Last process detail#####################
#	}
	$content->{data}=\@datalist;
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
