use inc::Module::Install;

all_from 'lib/Test/Sweet.pm';

requires 'Test::Builder'   => '0.94';
requires 'Test::More';
requires 'Test::Exception';
requires 'Test::Harness'   => '3.17';
requires 'Devel::Declare'  => '0.005011';
requires 'MooseX::Declare' => '0.31';
requires 'Moose'           => '0.92';
requires 'List::MoreUtils';
requires 'MooseX::Runnable';

license 'Perl';
repository 'http://github.com/jrockway/test-sweet';

WriteAll;
