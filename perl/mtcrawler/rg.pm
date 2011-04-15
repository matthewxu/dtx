#!/usr/bin/perl
package rg;

sub specialtag{
	my($self,$string)=@_;
	my @slist=split /\[\[/,$string;
	my @specialtag=('\\\\','\^','\$','\*','\.','\+','\?','\|','\/','\[','\]','\{','\}');
	my $return='';	
	while (my $s=pop @slist){
			foreach my $tag(@specialtag){
				$s=~s/$tag/$tag/ig;
			}
		$return=$s.$return;
		$s=pop @slist;
		$return=$s.$return;			
	}
	$return=~s/ +$//ig;
	return $return;
}

1;