use MooseX::Declare;

role Test::Sweet::Exception {
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
}
