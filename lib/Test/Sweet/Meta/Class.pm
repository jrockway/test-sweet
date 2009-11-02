use MooseX::Declare;

role Test::Sweet::Meta::Class {
    use MooseX::Types::Moose qw(Str ArrayRef ClassName Object);
    use Test::Sweet::Meta::Method;

    has 'tests' => (
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

    method _build_test_metaclass {
        return $self->create_anon_class(
            superclasses => [ $self->method_metaclass ],
            roles        => $self->test_metamethod_roles,
            cache        => 1,
        );
    }

    method add_test(Str $name, CodeRef $code) {
        my $body = $self->test_metaclass->name->wrap(
            $code,
            original_body => $code,
            name          => $name,
            package_name  => $self->name,
        );
        $self->add_method( $name, $body );
        $self->_add_test($name);
    }
}

