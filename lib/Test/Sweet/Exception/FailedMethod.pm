use MooseX::Declare;

class Test::Sweet::Exception::FailedMethod with Test::Sweet::Exception {
    has [qw/class method/] => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );
}
