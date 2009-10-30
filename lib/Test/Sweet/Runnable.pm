use MooseX::Declare;

role Test::Sweet::Runnable with MooseX::Runnable {
    use Test::More;
    
    method run {
        $self->$_ for $self->meta->tests;
        done_testing;
        exit 0;
    }
}

1;
