package Log::Dispatch::TAP;

# ABSTRACT: Log to TAP output

use v5.10.0;
use strict;
use warnings;

use Params::ValidationCompiler qw/ validation_for /;
use Types::Standard qw/ Enum /;
use Test2::API qw/ context /;

use base qw/ Log::Dispatch::Output /;

=head1 SYNOPSIS

  use Log::Dispatch;

  my $logger = Log::Dispatch->new(
    outputs => [
      [
         'TAP',
         method    => 'note',
         min_level => 'debug',
    ]
  );

=head1 DESCRIPTION

This module provides a L<Log::Dispatch> output sink for logging to
L<Test::Simple> diagnostics.

It is similar to L<Log::Dispatch::TestDiag>, except that it allows you
to choose the logging method.

=head1 CONSTRUCTOR

The constructor takes the following parameter in addition to the
standard parameters for L<Log::Dispatch::Output>.

=head2 method

This is the logging method, which is either C<note> or C<diag>
(corresponding to those functions in L<Test::More>).

=cut

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

=for Pod::Coverage log_message

=cut

sub log_message {
    my $self   = shift;
    my %p      = @_;
    my $ctx    = context();
    my $method = $ctx->can( $self->{method} );
    $ctx->$method( $p{message} );
    $ctx->release;
    return;
}

=head1 SEE ALSO

L<Log::Log4perl::Appender::TAP>

L<Log::Dispatch::TestDiag>

=head1 append:AUTHOR

Some of the code was adapted from L<Log::Log4perl::Appender::TAP>
and L<Log::Dispatch::TestDiag>.

=cut

1;
