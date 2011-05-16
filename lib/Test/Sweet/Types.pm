package Test::Sweet::Types;
# ABSTRACT: types used internally
use strict;
use warnings;

use MooseX::Types -declare => [qw/SuiteClass/];
use MooseX::Types::Moose qw(Object);
use Moose::Util qw(does_role);

subtype SuiteClass, as Object, where {
    return does_role($_->meta, 'Test::Sweet::Meta::Class');
};

1;
