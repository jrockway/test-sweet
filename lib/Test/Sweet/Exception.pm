use MooseX::Declare;

role Test::Sweet::Exception {
    has 'error' => (
        is       => 'ro',
        isa      => 'Any',
        required => 1,
    );
}
