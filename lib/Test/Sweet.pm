package Test::Sweet;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use Test::Sweet::Meta::Class;
use Test::Sweet::Meta::Method;

use Devel::Declare;
use Test::Sweet::Keyword::Test;

our $VERSION = '0.00_01';

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

    setup_sugar_for($for);
    load_extra_modules_into($for) unless $options{no_extra_modules};

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

sub load_extra_modules_into {
    my $pkg = shift;
    eval "package $pkg; use Test::More; use Test::Exception";
}

1;
__END__

=head1 NAME

Test::Sweet - Moose-based Test::Class replacement

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

   1..2
     ok 1 - can get record 42
     1..1
   ok 1 - subtest add_record
     ok 1 - still have record 42
     ok 2 - deleting 42 lives
     ok 3 - record 42 is gone
     1..3
   ok 2 - subtest delete_record

No more counting tests; this module does it for you and ensures that
you are protected against premature death.  (Well, your test suite,
anyway.)

You can also have command-line args for your tests; they are parsed
with L<MooseX::Getopt|MooseX::Getopt> (if you have it installed; try
"mx-run t::YourTest --help").

=head1 DESCRIPTION

C<Test::Sweet> lets you organize tests into Moose classes and Moose
roles.  You just need to create a normal class or role and say C<use
Test::Sweet> somewhere.  This adds the necessary methods to your
metaclass, makes your class do C<Test::Sweet::Runnable> (so that you
can run it with L<MooseX::Runnable|MooseX::Runnable>'s
L<mx-run|mx-run> command), and makes the C<test> keyword available for
your use.  (The imports are package-scoped, of course, but the C<test>
keyword is lexically scoped.)

Normal methods are defined normally.  Methods that run tests are
defined like methods, but with the C<test> keyword instead of C<sub>
or C<method>.  In the test methods, you can use any
L<Test::Builder|Test::Builder>-aware test methods.  You get all of
L<Test::More|Test::More> and L<Test::Exception|Test::Exception> by
default.

Tests can be called as methods any time the test suite is running,
including in BUILD and DEMOLISH.  Everything will Just Work.  The
method will get the arguments you pass, you will get the return value,
and this module will do what's necessary to ensure that Test::Builder
knows what is going on.  It's a Moose class and tests are just special
methods.  Method modifiers work too.  (But don't run tests directly in
the method modifier body yet; just call other C<test> methods.)

To run all tests in a class (hierarchy), just call the C<run> method.

Tests are ordered as follows.  All test method from the superclasses
are run first, then your tests are run in the order they appear in the
file (this is guaranteed, not a side-effect of anything), then any
tests you composed in from roles are run.  If anything in the
hierarchy overrides a test method from somewhere else in the
hierarchy, the overriding method will be run when the original method
would be.

Here's an example:

  class A { use Test::Sweet; test first { pass 'first' } };
  class B extends A { use Test::Sweet; test second { pass 'second' } };

When you call C<< A->run >>, "first" will be run.

When you call C<< B->run >>, "first" will run, then "second" will run.

If you change B to look like:

  class B extends A {
      test second { pass 'second' }
      test first  { pass 'blah'   }
  }

When you run C<< B->run >>, first will be called first but will print
"blah", and second will be called second.  (If you remove the "extends
A", they will run in the order they appear in B, of course; second
then first.)

=head1 REPOSITORY

L<http://github.com/jrockway/test-sweet>

Patches (or pull requests) are very welcome.  You should also discuss
this module on the moose irc channel at L<irc://irc.perl.org/#moose>;
nothing is set in stone yet, and your feedback is requested.

=head1 TODO

Convince C<prove> to run the <.pm> files directly.

Write code to organize classes into test suites; and run the test
suites easily.  (Classes and tests should be tagged, so you can run
C<run-test-suite t::Suite --no-slow-tests> or something.)

More testing.  There are undoubtedly corner cases that are
undiscovered and unhandled.

=head1 SEE ALSO

L<http://github.com/jrockway/test-sweet-dbic> shows what sort of
reusability you can get with C<Test::Sweet>... with 5 minutes of
hacking.

Read this module's test suite (in the C<t/> directory) for example of
how to make C<prove> understand C<Test::Sweet> classes.

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2009 Jonathan Rockway.

This module is free software, you may redistribute it under the same
terms as Perl itself.
