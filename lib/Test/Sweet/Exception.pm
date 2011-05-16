package Test::Sweet::Exception;
# ABSTRACT:
use Moose::Role;
use namespace::autoclean;

has 'error' => (
    is       => 'ro',
    isa      => 'Any',
    required => 1,
);

has [qw/class method/] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

1;

