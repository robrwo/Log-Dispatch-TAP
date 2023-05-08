package Log::Dispatch::TAP;

# ABSTRACT: Log to TAP output

use v5.14;
use warnings;

use Params::ValidationCompiler qw/ validation_for /;
use Types::Standard qw/ Enum /;
use Test2::API qw/ context /;

use base qw/ Log::Dispatch::Output /;

use namespace::autoclean;

our $VERSION = 'v0.2.2';

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

It is similar to L<Log::Dispatch::TestDiag>.

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

=head1 SUPPORT FOR OLDER PERL VERSIONS

Since v0.2.0, the this module requires Perl v5.14 or later.

Future releases may only support Perl versions released in the last ten years.

If you need this module on Perl v5.10, please use one of the v0.1.x
versions of this module.  Significant bug or security fixes may be
backported to those versions.

=head1 SEE ALSO

L<Log::Log4perl::Appender::TAP>

L<Log::Dispatch::TestDiag>

=head1 append:AUTHOR

Some of the code was adapted from L<Log::Log4perl::Appender::TAP>
and L<Log::Dispatch::TestDiag>.

=cut

1;
