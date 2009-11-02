use MooseX::Declare;

class t::Basic {
    use Test::Sweet;
    use Test::More;

    test does_it_work {
        pass 'it works';
        return (1,2,3) if wantarray;
        return 42;
    }

    test working_all_around {
        pass 'this also works';
        pass 'and do does this';
        pass 'it is working all around';
    }

    test method_call {
        my $result = $_[0]->does_it_work;
        is $result, 42, 'got return value';

        my @result = $_[0]->does_it_work;
        is_deeply \@result, [1,2,3], 'wantarray is preserved correctly';
    }
}
