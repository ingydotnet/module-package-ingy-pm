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
use Module::Package 0.17 ();
use Module::Install::AckXXX 0.15 ();
use Module::Install::ReadmeFromPod 0.12 ();
use Module::Install::Stardoc 0.13 ();
use Module::Install::VersionCheck 0.13 ();
use IO::All 0.41;
use YAML::XS 0.35 ();

our $VERSION = '0.05';

#-----------------------------------------------------------------------------#
package Module::Package::Ingy::modern;
use Moo;
extends 'Module::Package::Plugin';
use IO::All;

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
    $self->post_WriteAll(sub {$self->make_release});
}

sub make_release {
    my $makefile = io('Makefile')->all;
    $makefile .= <<'...';

release::
	$(PERL) "-Ilib" "-MModule::Package::Ingy" -e "Module::Package::Ingy->make_release()"

...
    io('Makefile')->print($makefile);
}

package Module::Package::Ingy;

# This is Ingy's personal release process. It probably won't match your own.
# It requires a YAML Changes file and git and tagged releases and other stuff.
sub make_release {
    my $class = shift or die;
    die "make release expects this to be a git repo\n\n"
        unless -e '.git';
    my $meta = YAML::XS::LoadFile('META.yml');
    my @changes = YAML::XS::LoadFile('Changes');
    die "Failed to load 'Changes'"
        unless @changes;
    my $change = shift @changes;
    die "Changes entry has more than 3 keys"
        if @{[keys %$change]} > 3;
    die "Changes entry does not define 'version', 'date' and 'changes'" unless
        exists $change->{version} and
        exists $change->{date} and
        exists $change->{changes};
    die "Changes entry 'date' should be blank for release\n\n"
        if $change->{date};
    my $changes_version = $change->{version};
    my $module_version = $meta->{version};
    die "'Changes' version '$changes_version' " .
        "does not match module version '$module_version'\n\n"
        unless $changes_version eq $module_version;
    my @lines = map {chomp; $_} sort `git tag`;
    my $tag_version = pop @lines or die;
    die "Module version '$module_version' is not 0.01 greater " .
        "than git tag version '$tag_version'"
        if abs($module_version - $tag_version - 0.01) > 0.0000001;
    my $date = `date`;
    chomp $date;
    my $Changes = io('Changes')->all;
    $Changes =~ s/date: *\n/date:    $date\n/ or die;
    system("perl Makefile.PL") == 0 or die;
    system("make purge") == 0 or die;
    my $status = `git status`;
    die "You have untracked files:\n\n$status"
        if $status =~ m!Untracked!;
    system("perl Makefile.PL") == 0 or die;
    system("make test") == 0 or die;
    system("sudo make install") == 0 or die;
    system("make manifest") == 0 or die;
    system("make upload") == 0 or die;
    system("make purge") == 0 or die;
    io('Changes')->print($Changes);
    system(qq{git commit -a -m "Released version $module_version"}) == 0 or die;
    system("git tag $module_version") == 0 or die;
    system("git push") == 0 or die;
    system("git push --tag") == 0 or die;
    $status = `git status`;
    die "git status is not clean:\n\n$status"
        unless $status =~ /\(working directory clean\)/;

    print <<"...";

$meta->{name}-$meta->{version} successfully released.

Relax. Have a beer.

...
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
