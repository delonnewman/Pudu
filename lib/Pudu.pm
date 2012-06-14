use v5.14;

# ABSTRACT: A light-weight Moose-like object system that makes it easy to create encapsulated, immutable objects

=head1 NAME

    Pudu - A light-weight Moose-like object system that makes it easy to create encapsulated, immutable objects

=head1 SYNOPSIS

    package Animal {
        use Pudu;

        has name => ( is => 'rw' );

        method speak => sub {
            "grunt"
        };

        private {
            method hide => sub {
                "this is my hiding place"
            };
        };

        protected {
            method share => sub {
                "I share with my friends"
            };
        };
    }

    package Cat {
        use Pudu;
        is 'Animal';

        method speak => sub {
            "meow"
        };

        method reveal => sub {
            self->share . " and strangers";
        };

        method betray => sub {
            self->hide
        };
    }

    $a = Animal->new(name => 'Bruce');
    $a->speak # => "grunt"
    $a->hide  # dies
    $a->share # dies

    $c = Cat->new(name => 'Selina');
    $c->speak  # => "meow"
    $c->reveal # => "I share with my friends and strangers"
    $c->betray # dies

=cut

use Pudu::Self;

package Pudu {
    use Data::Dump qw{ dump };

    my @current_scope = ();

    my %scopes = (
        private   => {},
        protected => {},
        method    => {}
    );
    
    my @exports = qw{ has is self private protected method };

    sub import {
        my $caller = caller(0);

        no strict;

        # export keywords
        *{"${caller}::$_"} = \&{$_} for @exports;

        require Pudu::Object;
        push @{"${caller}::ISA"}, 'Pudu::Object';

        *{"${caller}::ATTRIBUTES"}{HASH}; # create ATTRIBUTES namespace
        *{"${caller}::METHODS"}{HASH};    # create METHODS namespace

        use strict;
    }

=head1 FUNCTIONS

=head2 UTILITIES

=over

=item clean

Removes all keywords from from the given namespace.
It's used internally by C<Pudu::Object>.

Example:

    package Cat {
        use Pudu;

        has name => ( is => 'rw' );

        method speak => sub {
            "meow"
        };
    }

    my $c = Cat->new(name => "Selina");
    $c->name;   # => "Selina"
    $c->speak;  # => "meow"
    $c->has;    # dies
    $c->method; # dies

=cut

    sub clean {
        my $caller = shift || caller(0);

        delete $::{"${caller}::"}{$_} for @exports;
    }

=back

=head2 KEYWORDS

The following functions are all exported by default when using
the C<Pudu> module, and are designed to provide some
syntactic sugar for the inner workings.

=over

=item has

Keyword for defining attributes

Example:

    package Point {
        use Pudu;

        has x => ( is => 'rw' );
        has y => ( is => 'rw' );
    }

=cut

    sub has($@) {
        my ($attr, %props) = @_; 
        my $class = caller(0);

        $props{is} ||= 'ro'; # make read-only by default

        no strict 'refs';

        *{"${class}::$attr"} = sub {
            my ($self, $val) = @_;
            #dump $self;
            $self->($attr, $val);
        };

        *{"${class}::ATTRIBUTES"}->{$attr} = \%props;

        use strict 'refs';
    }

=item self

Keyword for recursively refering to the current object

Example:

    package Cat {
        use Pudu;

        has name => ( is => 'ro' );

        method speak => sub {
            "Meow... my name is " . self->name;
        };
    }

=cut

    my $self;
    sub self {
        my $class = caller(0);

        $self //= Encapsulated::Self->new($class, %scopes);
        $self->scope(@current_scope);

        $self;
    }

=item is

Keyword for establishing an 'is a' relationship between
a child class and it's parents.

Example:

    package Point3D {
        use Pudu;
        is 'Point';
    }

=cut

    sub is($@) {
        my @parents = @_;
        my $caller  = caller(0);

        no strict;

        my $isa = "${caller}::ISA";
        *$isa{ARRAY};
        push @{$isa}, @parents;

        use strict;

        # reset self
        $self = Pudu::Self->new(
            $caller => (
                protected => $scopes{protected},
                private   => {}
            )
        );
    }

=item does

Keyword for establishing a 'does' relationship between
a class and a Role.

NOTE: this does not work yet

Example:

    package LazyList {
        use Pudu;
        does 'Enumerable';
    }

=cut

    sub does($@) {

    }

=item private

Keyword for designating a private scope

Example:

    package Cat {
        use Pudu;

        private {
            method hide => sub {
                "hidden"
            };
        };
    }

    Cat->new->hide; # dies

=cut

    sub private(&) {
        $scopes{private} //= {};
        unshift @current_scope, 'private';
        shift->();
    }

=item protected

Keyword for designating a protected scope

Example:

    package Animal {
        use Pudu;

        protected {
            method share => sub {
                "I share with my friends"
            };
        };
    }

    package Cat {
        use Pudu;
        is 'Animal';

        method reveal => sub {
            self->share . " and with strangers"
        };
    }

    Animal->new->share; # dies
    Cat->new->reveal;   # => "I share with my friends and with strangers"

=cut

    sub protected(&) {
        unshift @current_scope, 'protected';
        $scopes{protected} //= {};
        shift->();
    }

=item method

Keyword for defining a method

Example:

    package Dog {
        use Pudu;

        method speak => sub {
            "bark"
        };
    }

=cut

    # define a method
    sub method($&) {
        my ($name, $blk) = @_;
        my $caller = caller(0);
        $scopes{method} //= {};

        # add to METHOD namespace
        no strict 'refs';
        *{"${caller}::METHODS"}->{$name} = {}; # not sure what information add
        use strict 'refs';

        my $scope = shift @current_scope;

        unshift @current_scope, 'method';

        given ($scope) {
            when ( 'private' ) {
                $scopes{$scope}->{$name} = $blk;
            }
            when ( 'protected' ) {
                $scopes{$scope}->{$name} = sub {
                    my ($self) = @_;
                    my $caller = caller(0);
                    if ( $caller eq ref $self ) {
                        $blk->(@_);
                    }
                    elsif ( $caller eq 'main' ) {
                        die "$name is a protected method";
                    }
                    else {
                        die "$name is a protected method";
                    }
                };
            }
            default {
                no strict 'refs';
                *{"${caller}::${name}"} = $blk;
                use strict 'refs';
            }
        }

        shift @current_scope;
    }
}

1;

__END__

=back

=head1 AUTHOR

Delon Newman <delon@cpan.org>

=head1 SEE ALSO

C<Moose>, C<Mouse>, C<Moo>, C<Mo>, C<Class::Closure>, C<Devel::EnforceEncapsulation>

=end
