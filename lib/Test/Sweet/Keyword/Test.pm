package Test::Sweet::Keyword::Test;
use strict;
use warnings;

use Devel::Declare ();
use Sub::Name;

use base 'Devel::Declare::Context::Simple';

sub install_methodhandler {
    my $class = shift;
    my %args  = @_;
    {
        no strict 'refs';
        *{$args{into}.'::test'} = sub (&) {};
    }

    my $ctx = $class->new(%args);
    Devel::Declare->setup_for(
        $args{into}, {
            test => { const => sub { $ctx->parser(@_) } },
        }
    );
}

sub parse_proto {
    my ($self, $proto) = @_;
    # todo: warn about bad syntax
    return [ grep { /[A-Za-z]+/} split /[^:_A-Za-z0-9+]+/, $proto ];
}

sub parser {
    my $self = shift;
    $self->init(@_);

    $self->skip_declarator;
    my $name = $self->strip_name;
    my $raw_proto = $self->strip_proto || '';
    my $attrs = $self->strip_attrs || '';
    my $requested_traits = $self->parse_proto($raw_proto . ' '. $attrs); # why not let attrs be used too?

    my $inject = $self->scope_injector_call();
    $self->inject_if_block($inject. " my \$self = shift; my \$test = shift; ");

    my $pack = Devel::Declare::get_curstash_name;
    Devel::Declare::shadow_sub("${pack}::test", sub (&) {
        my $test_method = shift;
        $pack->meta->add_test( $name, $test_method, $requested_traits );
    });

    return;
}

1;

__END__

=head1 NAME

Test::Sweet::Keyword::Test - provides the C<test> keyword

