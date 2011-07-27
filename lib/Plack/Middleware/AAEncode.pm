package Plack::Middleware::AAEncode;
use strict;
use parent qw(Plack::Middleware);
use utf8;
use Plack::Util;
use Path::Class qw(file);
use Encode qw(encode_utf8 decode_utf8);
our $VERSION = '0.01';

my @aa = (
    "(c^_^o)",
    "(ﾟΘﾟ)",
    "((o^_^o) - (ﾟΘﾟ))",
    "(o^_^o)",
    "(ﾟｰﾟ)",
    "((ﾟｰﾟ) + (ﾟΘﾟ))",
    "((o^_^o) +(o^_^o))",
    "((ﾟｰﾟ) + (o^_^o))",
    "((ﾟｰﾟ) + (ﾟｰﾟ))",
    "((ﾟｰﾟ) + (ﾟｰﾟ) + (ﾟΘﾟ))",
    "(ﾟДﾟ) .ﾟωﾟﾉ",
    "(ﾟДﾟ) .ﾟΘﾟﾉ",
    "(ﾟДﾟ) ['c']",
    "(ﾟДﾟ) .ﾟｰﾟﾉ",
    "(ﾟДﾟ) .ﾟДﾟﾉ",
    "(ﾟДﾟ) [ﾟΘﾟ]"
);

my $head =
"ﾟωﾟﾉ= /｀ｍ´）ﾉ ~┻━┻   //*´∇｀*/ ['_']; o=(ﾟｰﾟ)  =_=3; c=(ﾟΘﾟ) =(ﾟｰﾟ)-(ﾟｰﾟ); "
  . "(ﾟДﾟ) =(ﾟΘﾟ)= (o^_^o)/ (o^_^o);"
  . "(ﾟДﾟ)={ﾟΘﾟ: '_' ,ﾟωﾟﾉ : ((ﾟωﾟﾉ==3) +'_') [ﾟΘﾟ] "
  . ",ﾟｰﾟﾉ :(ﾟωﾟﾉ+ '_')[o^_^o -(ﾟΘﾟ)] "
  . ",ﾟДﾟﾉ:((ﾟｰﾟ==3) +'_')[ﾟｰﾟ] }; (ﾟДﾟ) [ﾟΘﾟ] =((ﾟωﾟﾉ==3) +'_') [c^_^o];"
  . "(ﾟДﾟ) ['c'] = ((ﾟДﾟ)+'_') [ (ﾟｰﾟ)+(ﾟｰﾟ)-(ﾟΘﾟ) ];"
  . "(ﾟДﾟ) ['o'] = ((ﾟДﾟ)+'_') [ﾟΘﾟ];"
  . "(ﾟoﾟ)=(ﾟДﾟ) ['c']+(ﾟДﾟ) ['o']+(ﾟωﾟﾉ +'_')[ﾟΘﾟ]+ ((ﾟωﾟﾉ==3) +'_') [ﾟｰﾟ] + "
  . "((ﾟДﾟ) +'_') [(ﾟｰﾟ)+(ﾟｰﾟ)]+ ((ﾟｰﾟ==3) +'_') [ﾟΘﾟ]+"
  . "((ﾟｰﾟ==3) +'_') [(ﾟｰﾟ) - (ﾟΘﾟ)]+(ﾟДﾟ) ['c']+"
  . "((ﾟДﾟ)+'_') [(ﾟｰﾟ)+(ﾟｰﾟ)]+ (ﾟДﾟ) ['o']+"
  . "((ﾟｰﾟ==3) +'_') [ﾟΘﾟ];(ﾟДﾟ) ['_'] =(o^_^o) [ﾟoﾟ] [ﾟoﾟ];"
  . "(ﾟεﾟ)=((ﾟｰﾟ==3) +'_') [ﾟΘﾟ]+ (ﾟДﾟ) .ﾟДﾟﾉ+"
  . "((ﾟДﾟ)+'_') [(ﾟｰﾟ) + (ﾟｰﾟ)]+((ﾟｰﾟ==3) +'_') [o^_^o -ﾟΘﾟ]+"
  . "((ﾟｰﾟ==3) +'_') [ﾟΘﾟ]+ (ﾟωﾟﾉ +'_') [ﾟΘﾟ]; "
  . "(ﾟｰﾟ)+=(ﾟΘﾟ); (ﾟДﾟ)[ﾟεﾟ]='\\\\'; "
  . "(ﾟДﾟ).ﾟΘﾟﾉ=(ﾟДﾟ+ ﾟｰﾟ)[o^_^o -(ﾟΘﾟ)];"
  . "(oﾟｰﾟo)=(ﾟωﾟﾉ +'_')[c^_^o];"    #TODO
  . "(ﾟДﾟ) [ﾟoﾟ]='\\\"';"
  . "(ﾟДﾟ) ['_'] ( (ﾟДﾟ) ['_'] (ﾟεﾟ+"
  . "(ﾟДﾟ)[ﾟoﾟ]+ ";

sub call {
    my ( $self, $env ) = @_;
    my $res = $self->app->($env);
    $self->response_cb(
        $res,
        sub {
            my $res = shift;
            return unless defined $res->[2];

            my $h = Plack::Util::headers( $res->[1] );
            if ( $h->get('Content-Type') =~ m!/(?:json|javascript)! ) {
                my $js =
                  ref( $res->[2] ) eq 'Plack::Util::IOWithPath'
                  ? file( $res->[2]->path )->slurp
                  : $res->[2][0];
                my $out = $head;
                my @chars = unpack "U*", decode_utf8($js);
                for my $c (@chars) {
                    $out .= "(ﾟДﾟ)[ﾟεﾟ]+";
                    if ( $c <= 127 ) {
                        for ( map { $_ - 48 } unpack 'U*', sprintf( "%o", $c ) )
                        {
                            $out .= $aa[$_] . "+ ";
                        }
                    }
                    else {
                        $out .= "(oﾟｰﾟo)+ ";
                        for ( map { chr } unpack 'U*', sprintf( "%04x", $c ) ) {
                            $out .= $aa[ hex($_) ] . "+ ";
                        }
                    }
                }

                $out .= "(ﾟДﾟ)[ﾟoﾟ]) (ﾟΘﾟ)) ('_');";
                $out = encode_utf8($out);
                $res->[2] = [$out];
                $h->set( 'Content-Length', length $out );
                $h->set( 'Content-Type',
                  $h->get('Content-Type') . "; charset=utf-8" )
                    unless $h->get('Content-Type') =~ /;\s*charset\s*=\s*/;
                $h->set( 'X-AAEncode',     'encoded' );
            }
        }
    );
}

1;

__END__

=head1 NAME

=head1 SYNOPSIS

    enable "AAEncode";

=head1 DESCRIPTION

=head1 AUTHOR

Yasuhiro Matsumoto

=head1 SEE ALSO

L<Plack>

=cut

