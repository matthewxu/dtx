    use XML::XPath;
    use XML::XPath::XMLParser;
    
    my $xp = XML::XPath->new(filename => 't.t');
    my $xpreg='//form/div/div/div/div/ul/li/a/text()|//form/div/div/div/div/ul/li/a/@href'; 
    my $nodeset = $xp->find($xpreg); # find all paragraphs
    
    foreach my $node ($nodeset->get_nodelist) {
#        print "FOUND\n\n",             XML::XPath::XMLParser::as_string($node),            "\n\n";
	print $node->getValue."\n";
    }
