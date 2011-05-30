##
# name:      Module::Package::Ingy
# abstract:  Ingy's Module::Package Plugins
# author:    Ingy döt Net <ingy@ingy.net>
# license:   perl
# copyright: 2011
# see:
# - Module::Package

package Module::Package::Ingy;
use strict;
use 5.008003;
use Module::Package 0.12 ();
use Module::Install::AckXXX 0.11 ();
use Module::Install::ReadmeFromPod 0.12 ();
use Module::Install::Stardoc 0.13 ();
use Module::Install::VersionCheck 0.11 ();

our $VERSION = '0.04';

#-----------------------------------------------------------------------------#
package Module::Package::Ingy::modern;
use Moo;
extends 'Module::Package::Plugin';

sub main {
    my ($self) = @_;
    $self->mi->stardoc_make_pod;
    $self->mi->stardoc_clean_pod;
    $self->mi->readme_from($self->pod_or_pm_file);
    $self->check_use_test_base;
    $self->check_use_testml;
    $self->strip_extra_comments;
    $self->mi->ack_xxx;
#     $self->mi->sign;

    $self->post_all_from(sub {$self->mi->version_check});
}

=head1 SYNOPSIS

In your Makefile.PL:

    use inc::Module::Package 'Ingy:modern';

=head1 DESCRIPTION

This module defines the standard configurations for Module::Package based
Makefile.PLs, used by Ingy döt Net. You don't have to be Ingy to use it. If
you write a lot of CPAN modules, you might want to copy or subclass it under a
name matching your own CPAN id.

=head1 FLAVORS

Currently this module only defines the C<:modern> flavor.

=head2 :modern

In addition to the inherited behavior, this flavor uses the following plugins:

    - Stardoc
    - ReadmeFromPod
    - AckXXX
    - VersionCheck

It also conditionally uses these plugins if you need them:

    - TestBase
    - TestML

=head1 OPTIONS

This module does not add any usage options of than the ones inherited from
L<Module::Package::Plugin>.
