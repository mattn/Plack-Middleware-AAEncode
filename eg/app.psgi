use strict;
use warnings;
use utf8;
use lib 'lib';
use Plack::Builder;

my $app = sub { [] };

builder {
    enable 'AAEncode';
    enable 'Static', path => qr{^/}, root => ".";
    $app;
};
