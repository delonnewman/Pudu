#!/usr/bin/env perl 
use v5.14;
use Data::Dump qw{ dump };

#package Point {
#    use Encapsulated;
#
#    has x => ( is => 'rw' );
#    has y => ( is => 'rw' );
#
#    method 'distance' => sub {
#        shift->polar;
#    };
#
#    method 'polar' => sub {
#        self;
#    };
#
#    private {
#        method 'test' => sub {
#            "test"
#        };
#    };
#
#    protected {
#        method 'r' => sub {
#            "rectangular"
#        };
#    };
#
#
#}

#package Point3D {
#    use Encapsulated;
#    is 'Point';
#
##    say @ISA;
##    say @PROTECTED;
#
#    has z => ( is => 'ro' );
#
#    method 'rect' => sub {
#        say "calling 'rect'";
#        self->r
#    };
#}
#
#my $p = Point->new(x => 1, y => 2);
##say $p->distance;
#say $p->polar;
#$p->x(3);
#$p->y(4);
#say $p->x;
#say $p->y;

#my $p2 = Point3D->new(x => 1, y => 2, z => 3);
#say $p2->z;
#say $p2->rect;

use lib qw{ lib };

package Animal {
    use Encapsulated;

    has name => ( is => 'rw' );

    method test => sub {
        self->move;
    };

    private {
        method test2 => sub {
            "test"
        };
    };

    protected {
        method move => sub {
            "moving..."
        };
    };
}

package Cat {
    use Encapsulated;
    is 'Animal';

    method meow => sub {
        self->move;
    };

    method betray => sub {
        self->test2
    };
}

my $a = Animal->new(name => "wolverine");
dump $a->test;
$a->name("Wolverine");
dump $a->name;

my $c = Cat->new(name => "Leo");
dump $c->meow;
dump $c->name;
dump $c->betray;
