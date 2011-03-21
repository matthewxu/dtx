use MIME::Base64 qw(encode_base64);

use Digest::MD5 qw(md5 md5_hex md5_base64);

my $encoded = encode_base64('http://www.cnblogs.com/cxd4321/archive/2007/09/24/903917.html');

#print "$encoded\n";
 $ctx = Digest::MD5->new;
$data="http://www.cnblogs.com/cxd4321/archive/2007/09/24/903917.html";
 $ctx->add("http://www.cnblogs.com/cxd4321/archive/2007/09/24/903917.html");
# $ctx->addfile(*FILE);
 $digest = md5($data);
 print $digest,"\n";
 $digest = $ctx->digest;
 print $digest,"\n";
 $digest = $ctx->hexdigest;
 print $digest,"\n";
 $digest = $ctx->b64digest;
print $digest,"\n";
	__END__
