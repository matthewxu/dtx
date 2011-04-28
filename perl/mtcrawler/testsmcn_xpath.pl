    use XML::XPath;
    use Data::Dumper;
    use XML::XPath::XMLParser;
    use HTML::TreeBuilder::XPath;
    my $xp = HTML::TreeBuilder::XPath->new( );
    $xp->parse_file('testdata/crawlerdata/aeeea3f84d418adf0703b5b917be6f52');#key-mbphmlnflapm.html');
#    my $xpreg='//form/div/div/div/div/ul/li/a/text()|//form/div/div/div/div/ul/li/a/@href';
    my $xpreg='/html/body/div[2]/div[3]/div[5]/div[2]/div[2]/ul/li/div[1]/a'; 
    my $nodeset = $xp->findnodes($xpreg); # find all paragraphs
    for($nodeset->get_nodelist) {
		print $_->findvalue(q{text()})."\t".$_->findvalue(q{@href})."\n";
    }
