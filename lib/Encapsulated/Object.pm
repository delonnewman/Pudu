use Encapsulated;

package Encapsulated::Object {
    use Carp;

    sub new {
        my ($class, %args) = @_;
        my $obj = \%args;
        
        # remove syntactic sugar from Encapsulated module
        Encapsulated::clean($class);

        bless sub {
            my ($attr, $value, $props) = @_;

            if ( $props && $props->{is} && $props->{is} eq 'ro' ) {
                if ( $attr && $value ) {
                    carp "'$attr' is read-only";
                }
            }

            if    ( $attr && $value ) { $obj->{$attr} = $value }
            elsif ( $attr )           { $obj->{$attr} }
            else {
                carp "an attribute is required";
            }

        }, $class;
    }
}

1;

__END__

=head1 NAME

Encapsulated::Object - An encapsulated closure-based object

=head1 SYNOPSIS

=head1 AUTHOR

Delon Newman <delon@cpan.org>

=end
