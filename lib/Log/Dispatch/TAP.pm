package Log::Dispatch::TAP;

use v5.10.0;
use strict;
use warnings;

use Params::ValidationCompiler qw/ validation_for /;
use Types::Standard qw/ Enum /;
use Test2::API qw/ context /;

use base qw/ Log::Dispatch::Output /;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    state $validator = validation_for(
        params => {
            method => {
                type    => Enum[qw/ note diag /],
                default => 'note',
            },
        },
        slurpy => 1,
    );

    my %p = $validator->(@_);
    my $self = bless { method => $p{method} }, $class;
    $self->_basic_init(%p);
    return $self;
}

sub log_message {
    my $self   = shift;
    my %p      = @_;
    my $ctx    = context();
    my $method = $ctx->can( $self->{method} );
    $ctx->$method( $p{message} );
    $ctx->release;
    return;
}

1;
