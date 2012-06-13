
[[meta author="Delon Newman <delon@cpan.org>"]]

# NAME

    Pudu - A light-weight Moose-like object system that makes it easy to create encapsulated, immutable objects

# SYNOPSIS

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

# FUNCTIONS

## UTILITIES

- clean

Removes all keywords from from the given namespace.
It's used internally by `Encapsulated::Object`.

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

## KEYWORDS

The following functions are all exported by default when using
the `Encapsulated` module, and are designed to provide some
syntactic sugar for the inner workings.

- has

Keyword for defining attributes

Example:

    package Point {
        use Pudu;

        has x => ( is => 'rw' );
        has y => ( is => 'rw' );
    }

- self

Keyword for recursively refering to the current object

Example:

    package Cat {
        use Pudu;

        has name => ( is => 'ro' );

        method speak => sub {
            "Meow... my name is " . self->name;
        };
    }

- is

Keyword for establishing an 'is a' relationship between
a child class and it's parents.

Example:

    package Point3D {
        use Pudu;
        is 'Point';
    }

- does

Keyword for establishing a 'does' relationship between
a class and a Role.

NOTE: this does not work yet

Example:

    package LazyList {
        use Pudu;
        does 'Enumerable';
    }

- private

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

- protected

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

- method

Keyword for defining a method

Example:

    package Dog {
        use Pudu;

        method speak => sub {
            "bark"
        };
    }

# AUTHOR

Delon Newman <delon@cpan.org>

# SEE ALSO

`Moose`, `Mouse`, `Moo`, `Mo`, `Class::Closure`, `Devel::EnforceEncapsulation`