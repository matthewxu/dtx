    use XML::XPath;
    use XML::XPath::XMLParser;
    
    my $xp = XML::XPath->new(filename => 'bookstore.xml');
    
    my $nodeset = $xp->find("//attribute::lang"); # find all paragraphs
    
    foreach my $node ($nodeset->get_nodelist) {
            my $string=XML::XPath::XMLParser::as_string($node);
            
            print $node->getValue()."\n";
				#print $string."\n";
#			my $txp=XML::XPath->new($string);
#			my $tndset = $txp->findnodes("//price[child::following]/text()"); # find all paragraphs
#			my $tndset = $txp->findnodes("//following[parent::book]/text()"); # find all paragraphs
#			my $tndset = $txp->findnodes("//following[ancestor::book]/text()"); # find all paragraphs
#			foreach my $node2 ($tndset->get_nodelist) {
#				print $node2->getValue."\n";
#			}
    		
	}
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