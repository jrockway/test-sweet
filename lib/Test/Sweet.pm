package Test::Sweet;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use Test::Sweet::Meta::Class;
use Test::Sweet::Meta::Method;

our $VERSION = '0.00';

Moose::Exporter->setup_import_methods(
    also      => 'Moose',
    with_meta => ['test'],
);

sub init_meta {
    my ($m, %options) = @_;
    Moose->init_meta(%options);

    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class       => $options{for_class},
        metaclass_roles => ['Test::Sweet::Meta::Class'],
    );

    Moose::Util::MetaRole::apply_base_class_roles(
        for_class => $options{for_class},
        roles     => ['Test::Sweet::Runnable'],
    );
}

sub test(&$;@){
    my ($meta, $code, $name, %args) = @_;

    my $method = Test::Sweet::Meta::Method->wrap(
        $code,
        %args,
        package_name => $meta->name,
        name         => $name,
    );

    $meta->add_method( $name => $method );
    $meta->_add_test( $name );
}

1;
__END__

=head1 SYNOPSIS

Write test classes:

   class t::RecordBasic with t::lib::FakeDatabase {
       use Test::Sweet;

       test add_record {
           $self->database->insert( 42 => 'OH HAI' );
           ok $self->database->get_record('42'), 'can get record 42';
       }

       test delete_record {
           ok $self->database->exists('42'), 'still have record 42';
           lives_ok {
               $self->database->delete('42')
           } 'deleting 42 lives';
           ok !$self->database->exists('42'), 'record 42 is gone';
       }
   }

Run them:

   $ mx-run -Ilib t::RecordBasic

And get the valid TAP output:

     ok 1 - can get record 42
     1..1
   ok 1 - subtest add_record
     ok 1 - still have record 42
     ok 2 - deleting 42 lives
     ok 3 - record 42 is gone
     1..3
   ok 2 - subtest delete_record
   1..2

No more counting tests; this module does it for you and ensures that
you are protected against premature death.
