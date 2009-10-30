use MooseX::Declare;

class Test::Sweet::Meta::Method extends Moose::Meta::Method {
    use Sub::Name;
    use Test::More;

    has 'num_tests' => (
        is        => 'rw', # XXX
        isa       => 'Int',
        required  => 0,
        predicate => 'has_num_tests',
    );

    has 'original_body' => (
        is       => 'rw',
        isa      => 'CodeRef',
        required => 0, # XXX
    );

    around wrap($class: $code, @args) {
        my $self = $class->$orig($code, @args);

        my %params = @args;
        $self->num_tests($params{num_tests}) if exists $params{num_tests};
        $self->original_body($code);
        return $self;
    }

    around body {
        return (subname "<Test::Sweet test wrapper>", sub {
            &Test::More::subtest(
                $self->name =>
                  subname "<Test::Sweet subtest>", sub {
                      plan $self->num_tests if $self->has_num_tests;
                      $self->$orig->({}); # hashref for future use
                      done_testing unless $self->has_num_tests;
                  },
            );
        });
    }

    # ideally this would return true or false, but that will require
    # some Test::Builder work.
    method run_as_test {
        $self->body_as_test->();
        return;
    }
}
