use MooseX::Declare;

role t::RoleTest {
    use Test::Sweet;
    use Test::More;

    test from_role {
        pass 'tests can come from roles';
    }
}
