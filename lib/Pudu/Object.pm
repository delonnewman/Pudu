use Pudu;

package Pudu::Object {
    use Carp;
    use Data::Dump qw{ dump };

    sub new {
        my ($class, %args) = @_;
        my $obj = \%args;
        
        # remove syntactic sugar from Encapsulated module
        Pudu::clean($class); # FIXME: There's a better way to do this

        bless sub {
            my ($attr, $value) = @_;

#            dump scalar caller(0);
#            dump $attr;
#            dump $value;

            my %attrs = %{"${class}::ATTRIBUTES"};
            my %props = %{$attrs{$attr}};
#            dump %attrs;
#            dump %props;

            if ( %props && $props{is} && $props{is} eq 'ro' ) {
                if ( $attr && $value ) {
                    croak "'$attr' is read-only";
                }
            }

            if    ( $attr && $value ) { $obj->{$attr} = $value }
            elsif ( $attr )           { $obj->{$attr} }
            else {
                croak "an attribute is required";
            }

        }, $class;
    }
}

1;

__END__

=head1 NAME

Pudu::Object - An encapsulated closure-based object

=head1 SYNOPSIS

=head1 AUTHOR

Delon Newman <delon@cpan.org>

=end
