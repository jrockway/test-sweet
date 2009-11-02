use MooseX::Declare;

role Test::Sweet::Runnable with MooseX::Runnable {
    use Test::More;

    eval {
        require MooseX::Getopt;
        with 'MooseX::Getopt';
    };

    method run {
        my @tests = $self->meta->get_all_tests;
        plan tests => scalar @tests; # so you get a "progress bar"
        $self->$_ for @tests;
        exit 0;
    }
}

1;
