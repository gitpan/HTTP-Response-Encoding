package HTTP::Response::Encoding;
use warnings;
use strict;
our $VERSION = sprintf "%d.%02d", q$Revision: 0.4 $ =~ /(\d+)/g;

sub HTTP::Response::encoding {
    require Encode;
    my $self = shift;
    my $content_type = $self->headers->header('Content-Type');
    return unless $content_type;
    $content_type =~ /charset=([A-Za-z0-9_\-]+)/io;
    return unless $1;
    my $enc = Encode::find_encoding($1);
    return unless $enc;
    $self->{__encoding} = $enc;
    return $enc->name;
}

sub HTTP::Response::decoded_content {
    require Carp;
    require Encode;
    my $self = shift;
    return unless $self->content;
    unless ($self->encoding){
	Carp::croak("Cannot find encoding for ", $self->request->uri);
    }
    return $self->{__encoding}->decode($self->content);
}

=head1 NAME

HTTP::Response::Encoding - Adds encoding() to HTTP::Response

=head1 VERSION

$Id: Encoding.pm,v 0.4 2007/04/20 05:40:37 dankogai Exp dankogai $

=cut

=head1 SYNOPSIS

  use LWP::UserAgent;
  use HTTP::Response::Encoding;

  my $ua = LWP::UserAgent->new();
  my $res = $ua->get("http://www.example.com/");
  warn $res->encoding;
  print $res->decoded_content;

=head1 EXPORT

Nothing.

=head1 METHODS

This module adds the following methods to  L<HTTP::Response> objects.

=over 2

=item C<< $res->encoding >>

Tells the content encoding in the canonical name in L<Encode>.
Returns undef if it can't.

For most cases, you are more likely to successfully find encoding
after GET than HEAD.  HTTP::Response is smart enough to parse 

  <meta http-equiv="Content-Type" content="text/html; charset=whatever"/>

But you need the content to let HTTP::Response parse it.
If you don't want to retrieve the whole content but interested in its
encoding, try something like below;

  my $req =  HTTP::Request->new(GET => $uri);
  $req->headers->header(Range => "bytes=0-4095"); # just 1st 4k
  my $res = $ua->request($req);
  warn $res->encoding;

=item C<< $res->decoded_content >>

Returns C<< $res->content >> but decoded to Perl utf8 string.

Roughly equivalent to the code below.

  Encode::decode($res->encoding, $res->content)

Note it croaks when $res->encoding is false.  So you should check 
C<< $res->encoding >> before using this method.

  # i.e.
  $content = $res->decoded_content if $res->encoding.

Also note that the meta tag remains intact.

=back

=head1 INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-http-response-encoding at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTTP-Response-Encoding>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HTTP::Response::Encoding

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HTTP-Response-Encoding>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HTTP-Response-Encoding>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HTTP-Response-Encoding>

=item * Search CPAN

L<http://search.cpan.org/dist/HTTP-Response-Encoding>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of HTTP::Response::Encoding
