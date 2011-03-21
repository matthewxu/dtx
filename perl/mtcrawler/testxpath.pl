    use XML::XPath;
    use XML::XPath::XMLParser;
    
    my $xp = XML::XPath->new(filename => 'bookstore.xml');
    
    my $nodeset = $xp->find("//book"); # find all paragraphs
    
    foreach my $node ($nodeset->get_nodelist) {
            my $string=XML::XPath::XMLParser::as_string($node);
				#print $string."\n";
			my $txp=XML::XPath->new($string);
#			my $tndset = $txp->findnodes("//price[child::following]/text()"); # find all paragraphs
#			my $tndset = $txp->findnodes("//following[parent::book]/text()"); # find all paragraphs
			my $tndset = $txp->findnodes("//following[ancestor::book]/text()"); # find all paragraphs
			foreach my $node2 ($tndset->get_nodelist) {
				print $node2->getValue."\n";
			}
    		
	}

	
