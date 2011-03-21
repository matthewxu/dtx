#!/usr/bin/perl

package sm;
$VERSION = 0.1;

use strict;
use warnings;
no warnings qw(uninitialized numeric);

use Data::Dumper;
use Carp;
use Mail::Sender;
$|++;
# ========================================================================================

sub new {
	my ($class,%args) = @_;
	my $self = bless {},$class;
	$self->{'smtp'} = $args{'smtp'} || 'smtp-relay.vclk.net' ;
	$self->{'debug'} = $args{'debug'};
	
	return $self;
} 

sub send_email
{
	my($self,%args)	= @_;
	my $subject	= $args{'subject'};
	my $text 	= $args{'text'};
	my $header  = $args{'header'};
	my $file 	= $args{'file'} || '';
	my $from	= $args{'from'} || 'matthewxu@live.com';
	my $to		= $args{'to'} || 'matthewatmezi@gmail.com';

	$to = 'matthewatmezi@gmail.com' if($self->{'debug'});
	
	my $sender;
	if (! ref ($sender = new Mail::Sender({	from => $from,
											smtp => $self->{'smtp'},
											})
	)){
		mydie ('Could not create a Mail::Sender Object',1);
	}

	if ($file && -e $file) {
		if ($header) {
			$sender->MailFile({to => "$to",
				subject => "$subject",
				headers => $header,
				msg => "$text",
				file => $file}) || croak "send_email: MailMsg failed";
		} else {
			$sender->MailFile({to => "$to",
					subject => "$subject",
					msg => "$text",
					file => $file}) || croak "send_email: MailMsg failed";
		}
	} else {
		if ($header) {
			$sender->MailMsg(	
				{	to => "$to",
					subject => "$subject",
					headers => $header,
					msg => "$text"
				}) || croak "send_email: MailMsg failed";
		} else {
			$sender->MailMsg(	
				{	to => "$to",
					subject => "$subject",
					msg => "$text"
				}) || croak "send_email: MailMsg failed";
		}
	}
	$sender->Close;	
	print "mail is sent successfully to $to ($subject)\n"; 
}

1;
__END__

