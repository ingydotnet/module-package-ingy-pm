##
# name:      Module::Package::Ingy
# abstract:  Ingy's Module::Package Plugins
# author:    Ingy döt Net <ingy@ingy.net>
# license:   perl
# copyright: 2010

package Module::Package::Ingy;
use strict;
use 5.008003;

our $VERSION = '0.01';

#-----------------------------------------------------------------------------#
package Module::Package::Ingy::modern;
use Moo 0.009007;
extends 'Module::Package::Plugin';

sub main {
    my ($self) = @_;
    $self->mi->stardoc_make_pod;
    $self->mi->readme_from($self->pod_or_pm_file);
    $self->mi->ack_xxx;
    $self->all_from($self->pm_file);
    $self->mi->requires_from($self->pm_file);
    $self->mi->version_check;
    $self->mi->stardoc_clean_pod;
}

=head1 SYNOPSIS

In your Makefile.PL:

    use inc::Module::Package 'Ingy';

=head1 DESCRIPTION

This module defines the standard configurations for Module::Package based
Makefile.PLs, used by Ingy döt Net. You don't have to be Ingy to use it. If
you write a lot of CPAN modules, you might want to copy or subclass it under a
name matching your own CPAN id.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
