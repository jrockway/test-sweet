use MooseX::Declare;

class Test::Sweet::Meta::Test {
    use MooseX::Types::Moose qw(CodeRef);
    use Test::Sweet::Types qw(SuiteClass);
    
    has 'test_body' => (
        is       => 'ro',
        isa      => CodeRef,
        required => 1,
    );

    method run(SuiteClass $suite_class, @user_args) {
        $self->test_body->($suite_class, $self, @user_args);
    }

    # so roles can before/after/around these
    method BUILD($args) { }
    method DEMOLISH()   { }
}
