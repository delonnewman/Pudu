use v5.14;
use Test::More;
use Test::Exception;

use lib qw{ lib };

package Animal {
    use Pudu;

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
    use Pudu;
    is 'Animal';

    method meow => sub {
        self->move;
    };

    method betray => sub {
        self->test2
    };
}

my $a = Animal->new(name => "wolverine");
is $a->test, "moving...", "should return 'moving...'";

$a->name("Wolverine");
is $a->name, "Wolverine", "should return 'Wolverine', not 'wolverine'";

my $c = Cat->new(name => "Leo");
is $c->meow, "moving...", "should return 'moving'";
is $c->name, "Leo", "should return 'Leo'";

throws_ok {
    $c->betray;
} qr{Can't locate object method}, "cannot betray";


done_testing;
