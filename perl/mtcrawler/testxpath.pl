use HTML::TreeBuilder::XPath;
my $xp = HTML::TreeBuilder::XPath->new();
my $file='testdata/crawlerdata/cfc367265c6d581f92fc53e4cdae170d.html';
$xp->parse_file($file);
my $xpath="//td[@class('cond')]";
my $xpath="id('proFilter')/table/tr/td[3]/a[1]";

				my $nodeset = $xp->findnodes($xpath);
				#store one piece of onething data inhash		
				foreach my $node ($nodeset->get_nodelist) {
					print "----------\n";
				}
#    use XML::XPath;
#    use XML::XPath::XMLParser;
#    
#    my $xp = XML::XPath->new(filename => 'testdata/crawlerdata/cfc367265c6d581f92fc53e4cdae170d.html');
#    
#    my $nodeset = $xp->find("/html/body/div/div/div/div/div/div/div/table/tbody/tr/td[3]/a"); # find all paragraphs
#    
#    foreach my $node ($nodeset->get_nodelist) {
#            my $string=XML::XPath::XMLParser::as_string($node);
#            
#            print $node->getValue()."\n";
#				#print $string."\n";
#			my $txp=XML::XPath->new($string);
#			my $tndset = $txp->findnodes("//price[child::following]/text()"); # find all paragraphs
#			my $tndset = $txp->findnodes("//following[parent::book]/text()"); # find all paragraphs
#			my $tndset = $txp->findnodes("//following[ancestor::book]/text()"); # find all paragraphs
#			foreach my $node2 ($tndset->get_nodelist) {
#				print $node2->getValue."\n";
#			}
#    		
#	}


#print '-------------------------------'."\n";
#my $nodestring='<b><a href="http://www.xungou.com/channel_houseware/" target="_blank">string....</a></b>';
#my $xp2=XML::XPath->new($nodestring);
#
#	
#my $nodeset2 = $xp2->find("//a/@href"); # find all paragraphs
#    
#foreach my $node2 ($nodeset2->get_nodelist) {
#			print $node2->getValue."\n";	
##            my $string2=XML::XPath::XMLParser::as_string($node2);
#            print $string2."\n";
#    		
#}
#	