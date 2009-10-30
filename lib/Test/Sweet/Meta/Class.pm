use MooseX::Declare;

role Test::Sweet::Meta::Class {
    use MooseX::Types::Moose qw(Str ArrayRef);

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
}
