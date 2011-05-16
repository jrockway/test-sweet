package Test::Sweet::Meta::Test;
# ABSTRACT:
use Moose;
use MooseX::Types::Moose qw(CodeRef);
use Test::Sweet::Types qw(SuiteClass);

use namespace::autoclean;

has 'test_body' => (
    is       => 'ro',
    isa      => CodeRef,
    required => 1,
);

sub run {
    my ($self, $suite_class, @user_args) = @_;
    $self->test_body->($suite_class, $self, @user_args);
}

# so roles can before/after/around these
sub BUILD    {}
sub DEMOLISH {}

1;

__END__
