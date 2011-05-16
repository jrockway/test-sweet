package Test::Sweet::Meta::Class;
# ABSTRACT: metaclass role that provides methods for keeping track of tests
use Moose::Role;
use MooseX::Types::Moose qw(Str ArrayRef ClassName Object);
use Test::Sweet::Meta::Method;
use Moose::Meta::Class;
use List::MoreUtils qw(uniq);

use namespace::autoclean;

has 'local_tests' => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef[Str],
    required   => 1,
    default    => sub { [] },
    auto_deref => 1,
    handles    => {
        '_add_test' => 'push',
    }
);

has 'test_metaclass' => (
    is         => 'ro',
    isa        => Object,
    lazy_build => 1,
);

has 'test_metamethod_roles' => (
    is         => 'ro',
    isa        => ArrayRef[ClassName],
    required   => 1,
    default    => sub { ['Test::Sweet::Meta::Method'] },
);

sub _build_test_metaclass {
    my $self = shift;
    return Moose::Meta::Class->create_anon_class(
        superclasses => [ $self->method_metaclass ],
        roles        => $self->test_metamethod_roles,
        cache        => 1,
    );
}

sub add_test {
    my ($self, $name, $code, $test_traits) = @_;
    my $body = $self->test_metaclass->name->wrap(
        $code,
        requested_test_traits => $test_traits || [],
        original_body         => $code,
        name                  => $name,
        package_name          => $self->name,
    );

    $self->add_method( $name, $body );
    $self->_add_test ( $name );
}

# ensure that we get the role's tests (they are available via the MOP, of course)
after 'add_role' => sub {
    my ($self, $role) = @_;
    if ( $role->can('local_tests') ) {
        $self->_add_test($role->local_tests);
    }
};

sub get_all_tests {
    my $self = shift;
    return $self->local_tests unless $self->can('linearized_isa');

    my @ordering = reverse $self->linearized_isa;
    my @tests = map {
        eval {
            my $meta = $_->meta;
            $meta->local_tests;
        };
    } @ordering;

    return uniq @tests;
}

1;

__END__

=head1 METHODS

=head2 get_all_tests

Returns the names of all test methods in this class' hierarchy.

=head2 local_tests

Returns the names of the test methods defined in this class.  Includes
tests composed in via roles.
