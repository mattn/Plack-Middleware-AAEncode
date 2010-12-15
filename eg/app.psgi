use strict;
use warnings;
use utf8;
use lib 'lib';
use Plack::Builder;
use Path::Class qw(file);

my $app = sub { [ 302, [ "Location" => "/index.html" ], [] ] };

builder {
    enable 'AAEncode';
    enable 'Static', path => qr{^/.}, root => file(__FILE__)->absolute->dir;
    $app;
};
