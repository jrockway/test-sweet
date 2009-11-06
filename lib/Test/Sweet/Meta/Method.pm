use MooseX::Declare;

role Test::Sweet::Meta::Method {
    use Sub::Name;
    use Test::Builder;
    use Try::Tiny;
    use Test::Sweet::Exception::FailedMethod;

    has 'original_body' => (
        is       => 'ro',
        isa      => 'CodeRef',
        required => 1,
    );

    requires 'wrap';
    requires 'body';

    around wrap($class: $code, %params) {
        my $self = $class->$orig($params{original_body}, %params);
        return $self;
    }

    around body {
        return (subname "<Test::Sweet test wrapper>", sub {
            my @args = @_;
            my $context = wantarray;
            my ($result, @result);

            my $b = Test::Builder->new; # TODO: let this be passed in
            $b->subtest(
                $self->name =>
                      subname "<Test::Sweet subtest>", sub {
                          try {
                              if($context){
                                  @result = $self->$orig->(@args);
                              }
                              elsif(defined $context){
                                  $result = $self->$orig->(@args);
                              }
                              else {
                                  $self->$orig->(@args);
                              }
                              $b->done_testing;
                          }
                          catch {
                              die Test::Sweet::Exception::FailedMethod->new(
                                  class  => $self->package_name,
                                  method => $self->name,
                                  error  => $_,
                              );
                          };
                      },
            );
            return @result if $context;
            return $result if defined $context;
            return;
        });
    }
}

__END__

=head1 NAME

Test::Sweet::Meta::Method - metamethod trait for running method as tests
