use v5.14;

package Pudu::Self {
    use Carp;
    use Data::Dump qw{ dump };

    sub new {
        my ($class, $klass, %scopes) = @_;
        bless { scopes => \%scopes, class => $klass }, $class;
    }

    sub scope {
        my ($self, @scope) = @_;

        if ( @scope ) { $self->{scope} = \@scope }
        else          { $self->{scope} }
    }

    sub class { shift->{class} }

    sub AUTOLOAD {
        my ($self) = @_;
        my $meth   = our $AUTOLOAD;
        $meth =~ s/.*:://;

        my %methods = (%{$self->{scopes}->{private}},
            %{$self->{scopes}->{protected}});
        
        if ( my $sub = $methods{$meth} ) {
            $sub->(@_);
        }
        elsif ( $self->class->can($meth) ) {
            $self->class->$meth;
        }
        elsif ( $meth eq 'DESTROY' ) {
            # do nothing
        }
        else {
            croak "Can't locate object method \"$meth\" via package \"", $self->class, '"';
        }
    }
}

1;

__END__

=head1 NAME

Pudu::Self - A magic object that helps to provide a 'self' keyword that respects privacy

=head1 SYNOPSIS

=head1 AUTHOR

Delon Newman <delon@cpan.org>

=end
