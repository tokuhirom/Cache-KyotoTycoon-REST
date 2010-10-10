package Cache::KyotoTycoon::REST;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use HTTP::Date;
use URI::Escape ();

use LWP::UserAgent;
use HTTP::Request;

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    my $ua = LWP::UserAgent->new(
        parse_head => 0,
        timeout    => defined( $args{timeout} ) ? $args{timeout} : 1,
        keep_alive => 1,
    );
    my $host = $args{host} || '127.0.0.1';
    my $port = $args{port} || 1978;
    my $base = "http://${host}:${port}/";
    bless {
        ua           => $ua,
        base         => $base,
    }, $class;
}

sub base { $_[0]->{base} }

sub get {
    my ($self, $key) = @_;
    my $res = $self->{ua}->get($self->{base} . URI::Escape::uri_escape($key));
    if ($res->code eq 200) {
        my $ret = $res->content;
        if (wantarray) {
            my $expires = HTTP::Date::str2time($res->header('X-Kt-XT'));
            return ($ret, $expires);
        } else {
            return $ret;
        }
    } elsif ($res->code eq 404) {
        return; # not found
    } else {
        die $res->status_line; # invalid response
    }
}

sub head {
    my ($self, $key) = @_;
    my $res = $self->{ua}->head($self->{base} . URI::Escape::uri_escape($key));
    if ($res->code eq 200) {
        my $expires = HTTP::Date::str2time($res->header('X-Kt-XT'));
        return $expires;
    } elsif ($res->code eq 404) {
        return; # not found
    } else {
        die $res->status_line; # invalid response
    }
}

sub put {
    my ($self, $key, $val, $expires_time) = @_;
    my $expires = $expires_time ? HTTP::Date::time2str(time() + $expires_time) : undef;
    my $req = HTTP::Request->new(
        PUT => $self->{base} . URI::Escape::uri_escape($key),
        [ $expires ? ('X-Kt-Xt' => $expires) : () ], $val
    );
    my $res = $self->{ua}->request($req);
    if ($res->code eq 201) {
        return 1;
    } else {
        undef;
    }
}

sub delete {
    my ($self, $key) = @_;
    my $req = HTTP::Request->new( DELETE => $self->{base} . URI::Escape::uri_escape($key));
    my $res = $self->{ua}->request($req);
    if ($res->code eq '204') {
        return 1;
    } elsif ($res->code eq '404') {
        return 0;
    } else {
        return undef;
    }
}

1;
__END__

=encoding utf8

=head1 NAME

Cache::KyotoTycoon::REST - Client library for KyotoTycoon RESTful API

=head1 SYNOPSIS

    use Cache::KyotoTycoon::REST;

    my $kt = Cache::KyotoTycoon::REST->new(host => $host, port => $port);
    $kt->put("foo", "bar", 100); # store key "foo" and value "bar".
    $kt->get("foo"); # => "bar"
    $kt->delete("foo"); # remove key

=head1 DESCRIPTION

Cache::KyotoTycoon::REST is

=head1 CONSTRUCTOR

=over 4

=back

=head1 METHODS

=over 4

=item my $val = $kt->get($key);

=item my ($val, $expires) = $kt->get($key);

Retrieve the value for a I<$key>.  I<$key> should be a scalar.

I<Return:> value associated with the I<$key> and I<$expires> time in epoch or undef.

=item my $expires = $kt->head($key);

Check the I<$key> is exists or not.

I<Return:> I<$expires> time in epoch or undef.

=item $kt->put($key, $val[, $expires]);

Store the I<$val> on the server under the I<$key>. I<$key> should be a scalar.
I<$value> should be defined and may be of any Perl data type.

I<$expires> is expire time in seconds relative from current time. This is not absolute epoch time.

I<Return:> 1 if server returns OK(201), or I<undef> in case of some error.

=item $kt->delete($key);

Remove cache data for $key.

I<Return:> 1 if server returns OK(200).  0 if server returns not found(404), or I<undef> in case of some error.

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
