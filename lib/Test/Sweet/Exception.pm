use MooseX::Declare;

role Test::Sweet::Exception {
    has 'error' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );
}
