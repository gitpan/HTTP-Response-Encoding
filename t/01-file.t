#!perl
#!perl -T

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Response::Encoding;
use File::Spec;
use Encode;
use Cwd;
use URI;
use Test::More tests => 7;

my $ua = LWP::UserAgent->new;
my $cwd = getcwd;

#BEGIN{
#    package LWP::Protocol;
#    $^W = 0;
#}

for my $meth (qw/encoding decoded_content/){
    can_ok('HTTP::Response', $meth);
}

for my $enc (qw/utf-8 euc-jp shiftjis iso-2022-jp/){
    my $uri = URI->new('file://');
    $uri->path(File::Spec->catfile($cwd, "t", "t-$enc.html"));
    my $res;
    {
	local $^W = 0; # to quiet LWP::Protocol
	$res = $ua->get($uri);
    }
    die unless $res->is_success;
    my $canon = find_encoding($enc)->name;
    is $res->encoding, $canon, "\$res->encoding eq '$canon'"; 
}

my $uri = URI->new('file://');
$uri->path(File::Spec->catfile($cwd, "t", "t-null.html"));
my $res = $ua->get($uri);
die unless $res->is_success;
eval {
    $res->decoded_content;
};
ok $@, $@;
