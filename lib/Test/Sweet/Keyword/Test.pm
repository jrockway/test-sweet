package Test::Sweet::Keyword::Test;
use strict;
use warnings;

use Devel::BeginLift;
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

sub parser {
    my $self = shift;
    $self->init(@_);

    $self->skip_declarator;
    my $name = $self->strip_name;
    $self->strip_proto;
    $self->strip_attrs;
    #$self->parse_proto($proto);

    my $inject = $self->scope_injector_call();
    $self->inject_if_block($inject. " my \$self = shift; ");

    my $pack = Devel::Declare::get_curstash_name;
    Devel::Declare::shadow_sub("${pack}::test", sub (&) {
        my $test_method = shift;
        $pack->meta->add_test( $name, $test_method );
    });

    return;
}

1;

