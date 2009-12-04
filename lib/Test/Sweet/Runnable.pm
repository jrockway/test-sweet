use MooseX::Declare;

role Test::Sweet::Runnable with MooseX::Runnable {
    use Test::More;
    use Try::Tiny;

    eval {
        require MooseX::Getopt;
        with 'MooseX::Getopt';
    };

    method run {
        my @tests = $self->meta->get_all_tests;
        plan tests => scalar @tests; # so you get a "progress bar"
        try {
            $self->$_ for @tests;
        }
        catch {
            if( ref $_ && blessed $_ && $_->can('does') && $_->does('Test::Sweet::Exception') ){
                diag "Test '". $_->method. "' in '". $_->class. "' failed". (
                  $_->isa('Test::Sweet::Exception::FailedMethod')               ?
                    ' by throwing an exception' :
                  $_->isa('Test::Sweet::Exception::FailedMetatestConstruction') ?
                    ' with an error in the metatest constructor' :
                  ''). ": ". $_->error;
            }
            else {
                diag "Test died: $_";
            }

            die $_; # rethrow for the "harness"
        };
        return 0;
    }
}

1;

__END__

=head1 NAME

Test::Sweet::Runnable - C<MooseX::Runnable> support for Test::Sweet classes
