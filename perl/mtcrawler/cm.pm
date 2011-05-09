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
use Devel::Size qw(size total_size);
use cf;
use bs;
#my $COUNT=10000;
#my $bfilter = Bloom::Filter->new( error_rate => 0.0001, capacity => $COUNT );
#my $bfilter2 = Bloom::Filter->new( error_rate => 0.0001, capacity => $COUNT );
#my $hashcheck=();
my $cf;
sub new{
        my ($class, %args) = @_;
        my $self  = bless {}, $class;
        $self->{base}=$args{'base'}; 
        $self->{debug}=$args{'debug'}|| 1;
        $self->{config}=$args{'config'};
        $self->{refresh}=$args{'refresh'}|| 0;
        print "cm init....\n";
		$cf=new cf(%args);
	return $self
}

sub getnewbrowser{
	my($self,@others)=@_;
	my $args={'base'=>"$self->{base}",'config'=>"$self->{config}"};

	print Dumper \$args if($self->{debug});
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
	my($self,$url,$urltype,@others)=@_;
	my $urlmd5=md5_hex($url);
	$self->getDoneUrl()->add($urlmd5);
	$self->saveDoneUrl($url,$urlmd5) if($urltype eq 'durl');
	return 1;
}

#we just have 3 types of url: fileurl,same level url and next url(child), data mapping relation as following
#if url a has same url b,just same in file md5(a).url, and save in hash to return, crawler it and paser it later
#if url a has child url, same in md5(a).txt, and save in hash to return, crawler it and paser it later
#if url is file, download it right now 

sub digmapping{
	#mapping for content to save
	my($self,$url,$regxindex,$urltype,$mycontent,$file,@others)=@_;

	#check if download, or download it right away.
	unless($file){
		my $b=$self->getbrowser();
		$b->seturl($url);
		$file=$b->getCachedFile($url,'.html',$self->{refresh});
	}
	
	#now paser it according config
	my $mp=$cf->getmpcfV2()->{'mpv2'};
	print Dumper $mp if($self->{debug});
	my $content=();
	my @nurllist=();
	my @datalist=();
	my @surllist=();
	foreach my $regx (keys %$mp){
	#loop url regx
		print "$mp->{$regx}->{'index'}:$regxindex:$regx:$url>>$file \n";
		if(($url=~/$regx/ &&(!$regxindex)) || ($regxindex && $regxindex eq $mp->{$regx}->{'index'} ) ) {
			print "match ======================== \n";
			my $pagetype=$mp->{$regx}->{pagetype};
			print "match $pagetype\n" if($self->{debug}); 
			#xpath instants
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
					my %datahash=();
					############seconde XPath json iterator##get same level content##################
					foreach $data(@$xpathlist){
						foreach my $xpath2(keys %$data){
								my $ntype=$data->{$xpath2};	
								my ($name,$type,$regxindex)=split '=',$ntype;
								print "xpath: $xpath2\n" if($self->{debug}); 
								my $nodevalue=$node->findvalue($xpath2);
								print "$name\t$nodevalue\t$type\n" if($self->{debug}); 
								if($type eq 'file' || $type eq 'img' ){
									#download and save path			
									my $bs=$self->getbrowser();
									$imgurl=$bs->fixurl($nodevalue);
									my $localpath=$bs->download($imgurl);
									$datahash{$name}=$localpath;														
								}elsif($type eq 'text'){
									#save text
									$datahash{$name}=$nodevalue;
								}elsif($type eq 'surl'){
									#same url
									my  $bs=$self->getbrowser();
									$fixedurl=$bs->fixurl($nodevalue); 
									push @surllist,"$fixedurl\t$regxindex\t0" ;#unless($hashcheck->{md5($fixedurl)});
									print "surl: $regxindex\t$fixedurl\n" if($self->{debug}); 
								}elsif($type eq 'nurl'){
									#next url.
									#todo callback or call another digmappings
									#need to do it right now or later in same piece of data
									my $bs=$self->getbrowser();
									my $fixedurl=$bs->fixurl($nodevalue);
									$datahash{nurl}=$fixedurl;
									$datahash{regxindex}=$regxindex; 
									push @nurllist,"$fixedurl\t$regxindex\t0" ;# unless($hashcheck->{md5($fixedurl)} );
								}else{
				                	$datahash{$name}=$nodevalue;
				                }	
						} 
					}
					push @datalist, \%datahash;
					#################################
				}
			}
			
		}else{
			print "not match \n";
		}
	}
	#now we save data
	#1 save same level urls
	$self->saveURLResult(\@surllist,'same');
	$self->saveURLResult(\@nurllist,'next');
	#2 save datainfo
	#and save next level urls 
	$self->saveDataResult(\@datalist,$url);
	print "we get dataset:".scalar(@datalist)."\n";
	##### deal with need-to-be-handle url in datalist;
#	$content->{surl}=\@surllist if(scalar @surllist>0);		
#	$content->{nurl}=\@nurllist if(scalar @nurllist>0);
	return $content;	
}


sub saveDataResult{
	my($self,$result,$url,@others)=@_;
    return () unless(scalar(@$result)>0);
    my $resultfile=$cf->{'resultdata'}."/".md5_hex($url).".txt".$self->{batchid};
    print $resultfile."\n";
    my $fh;
	$fh=new FileHandle();
    $fh->open("> $resultfile") || die "$resultfile fail\n";
	$fh->autoflush(1);       
	my $title=();	
	my $istitle=0;
	foreach my $piecedata(@$result){

		my	$cols;
		if(defined $title->{cols}){
			$cols=$title->{cols};
		}
		my $linedata='detail::';
		my $titleline='##title';
		foreach my $colname(sort {$a<=>$b} keys %$piecedata){
			if(defined $title->{cols}){
				unless(defined	$cols->{$colname}){
					die "defined unuint col $colname\n";
				}
			}else{
				$title->{$colname}=1;
			}
			$titleline.="\t".$colname;
			$linedata.="\t".$piecedata->{$colname};
		}
		unless($istitle){
			print $fh $titleline."\n";	
			$istitle=1;
		}
		$title->{cols}=$cols;
#		print $linedata."\n";
		
		print $fh $linedata."\n";
	}
	close $fh;
	return 1;
}

sub saveURLResult{
	my($self,$urls,$type,$url,@others)=@_;
	return unless(scalar(@$urls)>0);
    my $resultfile=$cf->{'resultdata'}."/$type.url.txt".$self->{batchid};
    print $resultfile."\n";
    my $fh;

	$fh=new FileHandle();
    $fh->open(">> $resultfile") || die "$resultfile fail\n";
	$fh->autoflush(1);    
	foreach my $surl(@$urls){
		print $fh "$surl\n";	
	}	   
	close $fh;
}

sub getBFDoneUrl{
    my($self,$type,@others)=@_;
	if(defined $self->{bfilter}){
		return $bfilter;
	}        
    my $urltofile=$cf->{$type}.$self->{batchid};
    unless(-e $urltofile) {return $bfilter};
    my $fh=new FileHandle();
    $fh->open($urltofile) || die "$urltofile fail\n";
	while(my $l=<$fh>){
		chomp($l);
		my($md5,$url)=split '\t',$l;
		$bfilter->add($md5);
	}	
	close $fh;
	$self->{bfilter}=$bfilter;
	return $bfilter;
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
	my($self,$url,$regxindex,$urltype,$mycontent,$file,@others)=@_;

	unless($file){
		my $b=$self->getbrowser();
		$b->seturl($url);
		$file=$b->getCachedFile($url);
	}
	my $mp=$cf->getmpcfV2()->{'mpv2'};
	print Dumper $mp if($self->{debug});
	my $content=();
	if($self->isDone($url)){
		$content->{data}=();
	 	return $content;
	 }
	my @tocrawlerurl=();
	my @datalist=();
	foreach my $regx (keys %$mp){
	#loop url regx
		print "$mp->{$regx}->{'index'}:$regxindex;;$regx:$url>>$file \n";
		if(($url=~/$regx/ &&(!$regxindex)) || ($regxindex && $regxindex eq $mp->{$regx}->{'index'} ) ) {
			print "match ======================== \n";
			my $pagetype=$mp->{$regx}->{pagetype};
			print "match $pagetype\n" if($self->{debug}); 
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
					my %datahash=();
					############seconde XPath json iterator##get same level content##################
					foreach $data(@$xpathlist){
						foreach my $xpath2(keys %$data){
							my $ntype=$data->{$xpath2};	
							my ($name,$type,$regxindex)=split '=',$ntype;
							print "xpath: $xpath2\n" if($self->{debug}); 
								my $nodevalue=$node->findvalue($xpath2);
								print "$name\t$nodevalue\t$type\n" if($self->{debug}); 
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
									print "surl: $fixedurl\n" if($self->{debug}); 
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
									print "lurl: $fixedurl\n" if($self->{debug}); 
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
									print "nurl: $fixedurl\n" if($self->{debug}); 
									push @tocrawlerurl,\%tmpurls;#crawler it later
								}elsif($type eq 'aurl'){
									#anotherurl: eg. computerpage=>dellpage save "computer=>dell dellpageurl"
									my $bs=$self->getbrowser();
									my $fixedurl=$bs->fixurl($nodevalue);
									$datahash{aurl}=$fixedurl;	
									$datahash{regxindex}=$regxindex;
									print "aurl: $fixedurl\n" if($self->{debug}); 						                                
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
	$self->urlDone($url,$urltype);
	print "we get dataset:".scalar(@datalist)."\n";
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
			undef($return->{data});
		}
	}
	
	if(scalar(@tmpdatalist)>0){
		@datalist=@tmpdatalist;
	}
	print "we get dataset:".scalar(@datalist)."\n";


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
			undef($return->{data});
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
	undef(@tocrawlerurl);
	####durl:detail url, also the last url,Last Data set , Not store in Memory###
	#TODO####Store into DB or File#########
#	@tmpdatalist=();
	foreach my $piecedata(@datalist){
		if(defined $piecedata->{durl} ){
			print "durl::::>>>>>>>>> $piecedata->{durl},$piecedata->{regxindex}\n";
			my $return=$self->digmappingv2($piecedata->{durl},$piecedata->{regxindex},'durl');
			print "durl.... $piecedata->{durl}\n" if($self->{debug}); 
			my $returncontent =$return->{data};
			delete $piecedata->{regxindex};
			print Dumper $returncontent if($self->{debug});
			foreach my $onedata (@$returncontent){
				foreach my $d(keys %$piecedata){
					$onedata->{$d}=$piecedata->{$d};
				}
				my %savedata=%$onedata;
#				push @tmpdatalist,\%savedata;

				my	$cols;
				if(defined $self->{cols}){
					$cols=$self->{cols};
				}
				my $linedata='detail::';
				my $titleline='##title';
				foreach my $colname(sort {$a<=>$b} keys %savedata){
					if(defined $self->{cols}){
						unless(defined	$cols->{$colname}){
							die "defined unuint col $colname\n";
						}
					}else{
						$cols->{$colname}=1;
						
						
					}
					$titleline.="\t".$colname;
					$linedata.="\t".$savedata{$colname};
				}
				unless(defined $self->{cols}){
					$self->saveResult($titleline);	
				}
				$self->{cols}=$cols if($cols);
				print $linedata."\n";
				
				$self->saveResult($linedata);
			}


			undef($return->{data});
			delete $piecedata->{durl};
		}
	}
	$content->{data}=\@datalist;
	return $content;	
}


sub isDone{
	my($self,$url,@others)=@_;
	my $bfilterurls=$self->getDoneUrl();
	if($bfilterurls->check(md5_hex($url))){
		return 1;
	}
	return 0;
}




sub saveResult{
	my($self,$result,@others)=@_;
    my $resultfile=$cf->{'result'}.$self->{batchid};
    print $resultfile."\n";
    my $fh;
	if(defined $self->{resulthandle}) {
		$fh= $self->{resulthandle};
	}else{
		$fh=new FileHandle();
        $fh->open(">> $resultfile") || die "$resultfile fail\n";
		$fh->autoflush(1);       
	 	$self->{resulthandle}=$fh;
	}
	print $fh "$result\n";
}



sub saveDoneUrl{
	my($self,$url,$key,@others)=@_;
    my $urltofile=$cf->{'urltofile'}.$self->{batchid};
    print $urltofile."\n";
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
    my $urltofile=$cf->{'urltofile'}.$self->{batchid};
    unless(-e $urltofile) {return $bfilter};
    my $fh=new FileHandle();
    $fh->open($urltofile) || die "$urltofile fail\n";
	while(my $l=<$fh>){
		chomp($l);
		my($md5,$url)=split '\t',$l;
		$bfilter->add($md5);
	}	
	close $fh;
	$self->{bfilter}=$bfilter;
	return $bfilter;
} 

sub print_size{
	my($self,$date,$name,@others)=@_;
	print "$name hash memory bytes>>>>>>>>>>>>:".size($data)."\n";
	print "$name total memory bytes>>>>>>>>>>>>:".total_size($data)."\n";
	print "$name data memory bytes>>>>>>>>>>>>:".(total_size($data)-size($data))."\n";
}
sub _destroy{
	my($self,@others)=@_;
	if(defined $self->{doneurlhandle}){
		close $self->{doneurlhandle};
		undef $self->{doneurlhandle};
	}
	if(defined $self->{resulthandle}){
		close $self->{resulthandle};
		undef $self->{resulthandle};
	}
}

1;
