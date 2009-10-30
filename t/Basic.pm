use MooseX::Declare;

class t::Basic {
    use Test::Sweet;
    use Test::More;

    test {
        pass 'it works';
    } 'does_it_work';

    test {
        pass 'this also works';
        pass 'and do does this';
        pass 'it is working all around';
    } 'working_all_around';
}
