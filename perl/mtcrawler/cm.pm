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
		print "$regx,$url:$file \n";
		if(($url=~/$regx/ &&(!$regxindex)) || ($regxindex && $regxindex eq $mp->{$regx}->{'index'} ) ) {
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
#					my $nodestring= XML::XPath::XMLParser::as_string($node);
					print "subNode: $nodestring\n";
#					my $xp2=XML::XPath->new($nodestring);
#					print Dumper $xp2;
#					die;
					my %datahash=();
										
					############seconde XPath json iterator##get same level content##################
					foreach $data(@$xpathlist){
						
						foreach my $xpath2(keys %$data){

							my $ntype=$data->{$xpath2};	
							my ($name,$type,$regxindex)=split '=',$ntype;
							print "xpath: $xpath2\n";
#							my $nodeset2 = $xp2->find($xpath2);	
#							foreach my $node2 ($nodeset2->get_nodelist) {
								my $nodevalue=$node->findvalue($xpath2);
								print "$name\t$nodevalue\t$type\n";
								if($type eq 'img'){
									#download and save path			
									my $imgurl=$self->{'bs'}->fixurl($nodevalue);
									my $localpath=$self->getbrowser()->download($imgurl);
									$datahash{$name}=$localpath;														
								}elsif($type eq 'text'){
									#save text
									$datahash{$name}=$nodevalue;
								}elsif($type eq 'surl'){
									#sub cc url
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
									$datahash{surl}=$fixedurl;
									$datahash{regxindex}=$regxindex;
									print "surl: $fixedurl\n";
								}elsif($type eq 'durl'){
									#detail url, this mean we are in list page.
									#todo callback or call another digmappings
									#need to do it right now or later in same piece of data
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
									$datahash{durl}=$fixedurl;
									$datahash{regxindex}=$regxindex;					
								}elsif($type eq 'lurl'){
									#list page url
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
#									push @tocrawlerurl,$fixedurl;#crawler it later
									$datahash{lurl}=$fixedurl;	
									$datahash{regxindex}=$regxindex;
								}
								elsif($type eq 'nurl'){
									#nexturl: eg. pagination "products fenye 1,2,,", just crawl it, not save the name or others
									# this mean we are in same page.
									#todo callback or call another digmappings
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
									my %tmpurls=();
									$tmpurls{'nurl'}=$fixedurl;
									$tmpurls{'regxindex'}=$regxindex;
									push @tocrawlerurl,\%tmpurls;#crawler it later
								}elsif($type eq 'aurl'){
									#anotherurl: eg. computerpage=>dellpage save "computer=>dell dellpageurl"
									my $fixedurl=$self->getbrowser()->fixurl($nodevalue);
									$datahash{aurl}=$fixedurl;	
									$datahash{regxindex}=$regxindex;							                                
#				                }elsif($type eq 'attach'){
#					               	#how to attachments 
#				                                
#				                }elsif($type eq 'texturl'){
#				                            
				                }else{
				                	$datahash{$name}=$nodevalue;
				                }	
				                #in my case,it should be just one data.
#				                last;										
#							}
						} 
					}
					#################################
#					print Dumper \%datahash;
					push @datalist, \%datahash;
				}
			}
			
		}else{
			print "not match \n";
		}
	}
#	print "start datalist--------------------\n";
#	print Dumper @datalist;
#	print "end datalist--------------------\n";
	##### deal with need-to-be-handle url in datalist;
	my $urlmd5=md5_hex($url);
	$content->{url}=$url;	
	
	my @tmpdatalist=();
	foreach my $piecedata(@datalist){
		if(defined $piecedata->{surl}){#subchannel url
			print "===============================================\n";
			my $return=$self->digmappingv2($piecedata->{surl});
			print "surl $piecedata->{surl}\n";
#			print Dumper $return; 
			my $returncontent =$return->{data};
			my $cc=$piecedata->{cc};
			print "cc:$cc .................\n";
			delete $piecedata->{surl};
			delete $piecedata->{cc};
			foreach my $onedata (@$returncontent){
				my $subcc=$onedata->{cc};
				$onedata->{cc}=$cc."=>".$subcc;
				print $cc."=>".$subcc."\n";
				foreach my $d(keys %$piecedata){
					$onedata->{$d}=$piecedata->{$d};
				}
				my %savedata=%$onedata;
				push @tmpdatalist,\%savedata;
#				print Dumper \%savedata;
			}
#			print "---------------\n";
#			print Dumper @tmpdatalist;
		}
	}
	if(scalar(@tmpdatalist)>0){
		@datalist=@tmpdatalist;
	}
#	print "start datalist 2--------------------\n";
#	print Dumper @datalist;
#	print "end datalist 2--------------------\n";

#####Last Data set , Not store in Memory###
#TODO####Store into DB or File#########
	@tmpdatalist=();
	foreach my $piecedata(@datalist){
		if(defined $piecedata->{durl}){#subchannel url
			print "===============================================\n";
			my $return=$self->digmappingv2($piecedata->{durl},$piecedata->{regxindex});
			print "durl $piecedata->{surl}\n";
#			print Dumper $return; 
			my $returncontent =$return->{data};
			delete $piecedata->{durl};
			delete $piecedata->{regxindex};
			foreach my $onedata (@$returncontent){
				foreach my $d(keys %$piecedata){
					$onedata->{$d}=$piecedata->{$d};
				}
				my %savedata=%$onedata;
				push @tmpdatalist,\%savedata;
#				print Dumper \%savedata;
				foreach my $colname(keys %savedata){
					print "Col:".$colname."\t".$savedata{$colname}."\n";
				}
			}
#			print "---------------\n";
#			print Dumper @tmpdatalist;
		}
	}
	if(scalar(@tmpdatalist)>0){
		@datalist=@tmpdatalist;
		#######!!!!!!!!!!!!!!#####################
		##Last process detail#####################
	}

	foreach my $piecedata(@datalist){

		if(defined $piecedata->{aurl}){#another url
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
#	print "start 3 datalist--------------------\n";
#	print Dumper @datalist;
#	print "end 3 datalist--------------------\n";
	
	foreach my $nurls(@tocrawlerurl){#next page url
		print "nurl:::: $nurls->{nurl}\n";
		my $return=$self->digmappingv2($nurls->{nurl},$nurls->{regxindex});
		my $returncontent =$return->{data};
		foreach my $onedata (@$returncontent){
			push @datalist,$onedata;
		}
		
	}
#	print "start content----------------\n";
	$content->{data}=\@datalist;
#	print Dumper $content;
#	print "end	content----------------\n";
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
