package Test::Sweet;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use Test::Sweet::Meta::Class;
use Test::Sweet::Meta::Method;

use Devel::Declare;
use Test::Sweet::Keyword::Test;

our $VERSION = '0.00';

Moose::Exporter->setup_import_methods();

sub init_meta {
    my ($me, %options) = @_;

    my $for = $options{for_class};


    # work on both roles and classes
    my $meta;
    if ($for->can('meta')) {
        $meta = $for->meta;
    } else {
        $meta = Moose::Role->init_meta(for_class => $for);
    }

    setup_sugar_for($options{for_class});

    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class       => $for,
        metaclass_roles => ['Test::Sweet::Meta::Class'],
    );

    if($meta->isa('Class::MOP::Class')){
        # don't apply this to roles
        Moose::Util::MetaRole::apply_base_class_roles(
            for_class => $for,
            roles     => ['Test::Sweet::Runnable'],
        );
    }
}

sub setup_sugar_for {
    my $pkg = shift;
    Test::Sweet::Keyword::Test->install_methodhandler(
        into => $pkg,
    );
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
you are protected against premature death.  (Well, your test suite,
anyway.)
