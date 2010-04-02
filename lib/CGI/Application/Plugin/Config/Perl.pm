package CGI::Application::Plugin::Config::Perl;
use base 'Exporter';
use Carp;
use strict;
use warnings;

our @EXPORT_OK = qw(
    cfg_file
    cfg
);

# For compliance with CGI::App::Standard::Config
# we break the rule and export config and std_config by default.
sub import {
  my $app = caller;
  no strict 'refs';
  my $full_name = $app . '::config';
  *$full_name = \&cfg;

  my $std_config_name = $app.'::std_config';
  *$std_config_name = \&std_config;
  CGI::Application::Plugin::Config::Perl->export_to_level(1,@_);
}


our $VERSION = '1.40';

# required by C::A::Standard::Config;
sub std_config { return 1; }

=pod

=head1 NAME

CGI::Application::Plugin::Config::Perl - Pure Perl config file management for CGI::Application

=head1 SYNOPSIS

 use CGI::Application::Plugin::Config::Perl 'cfg';

In your instance script:

 my $app = WebApp->new(PARAMS => { cfg_file => 'config.pl' });
 $app->run();

In your application module:

 sub my_run_mode {
    my $self = shift;

    # Access a config hash key directly
    $self->cfg('field');

    # Return config as hash
    %CFG = $self->cfg;

 }


=head1 DESCRIPTION

CGI::Application::Plugin::Config::Perl adds easy access to a pure Perl config
file to your L<CGI::Application|CGI::Application> projects.  Lazy loading is
used to prevent the config file from being parsed if no configuration variables
are accessed during the request, so the config file is not parsed
until it is actually needed.

I have been using pure Perl config files for almost a decade and find they work
very well. I originally wrote L<CGI::Application::Plugin::ConfigAuto> to
support all kinds of config files, but found that I only ever used Perl-based
config files. This module has the same interface as the ConfigAuto plugin,
without the option for other formats, and the extra dependency and resource use
that comes with that flexibility.

=head2 Why use Pure Perl config files

A pure Perl config file could be a great choice if your config files created
and maintained by Perl programmers. They have a number of benefits:

=over 4

=item *

There is no new syntax to learn beyond Perl

=item *

They support all features that Perl does

=item *

There is no resource overhead to parse a format and translate into Perl

=item *

There are no additional module dependencies

=back

=head2 Support for multiple config files

This plugin supports multiple config files for a single application, allowing
config files to override each other in a particular order. This covers even
complex cases, where you have a global config file, and second local config
file which overrides a few variables.

=head1 DECLARING CONFIG FILE LOCATIONS

It is recommended that you to declare your config file locations in the
instance scripts, where it will have minimum impact on your application. This
technique is ideal when you intend to reuse your module to support multiple
configuration files. If you have an application with multiple instance scripts
which share a single config file, you may prefer to call the plugin from the
setup() method.

 # In your instance script
 # value can also be an arrayref of config files
 my $app = WebApp->new(PARAMS => { cfg_file => 'config.pl' })

 # OR ...

 # Pass in an array of config files, and they will be processed in order.
 $app->cfg_file('../../config/config.pl');

Your config files should be referenced using the syntax example above. Note
that the key C<config_files> can be used as alternative to cfg_file.

=head1 METHODS

=head2 cfg()

 # Access a config hash key directly
 $self->cfg('field');

 # Return config as hash
 my %CFG = $self->cfg;

 # return as hashref
 my $cfg_href = $self->cfg;

A method to access project configuration variables. The config
file is parsed on the first call with a perl hash representation stored in memory.
Subsequent calls will use this version, rather than re-reading the file.

In list context, it returns the configuration data as a hash.
In scalar context, it returns the configuration data as a hashref.

=head2 config()

L<CGI::Application::Standard::Config/config()> is provided as an alias to cfg() for compliance with
L<CGI::Application::Standard::Config>. It always exported by default per the
standard.

=head2 std_config()

L<CGI::Application::Standard::Config/std_config()> is implemented to comply with L<CGI::Application::Standard::Config>. It's
for developers. Users can ignore it.

=cut

sub cfg {
    my $self = shift;

    if (!$self->{__CFG}) {
         unless ($self->{__CFG_FILES}) {
             my @all_cfg_files;
             for my $key (qw/cfg_file config_files/) {
                 my $cfg_file = $self->param($key);
                 if (defined $cfg_file) {
                     push @all_cfg_files, @$cfg_file  if (ref $cfg_file eq 'ARRAY');
                     push @all_cfg_files,  $cfg_file  if (ref \$cfg_file eq 'SCALAR');
                 }
             }

             # Non-standard call syntax for mix-in happiness.
             cfg_file($self,@all_cfg_files);
         }

        # Read in config files in the order the appear in this array.
        my %combined_cfg;
        for (my $i = 0; $i < scalar @{ $self->{__CFG_FILES} }; $i++) {
            my $file = $self->{__CFG_FILES}[$i];
            my %parms;
            if (ref $self->{__CFG_FILES}[$i+1] eq 'HASH') {
                %parms = %{ $self->{__CFG_FILES}[$i+1] };
                # skip trying to process the hashref as a file name
                $i++;
            }
            my $cfg = do $file;
            warn "couldn't parse $file: $@"       if $@;
            warn "couldn't do $file: $!"          unless defined $cfg;
            warn "$file didn't return a hashref"  unless ref $cfg eq 'HASH';

            %combined_cfg = (%combined_cfg, %$cfg);
        }
        die "No configuration found. Check your config file(s) including their syntax."
            unless keys %combined_cfg;

        $self->{__CFG} = \%combined_cfg;
    }

    my $cfg = $self->{__CFG};
    my $field = shift;
    return $cfg->{$field} if $field;
    if (ref $cfg) {
        return wantarray ? %$cfg : $cfg;
    }
}

=head2 cfg_file()

 $self->cfg_file('my_config_file.pl');

Supply an array of config files, and they will be processed in order.

=cut

sub cfg_file {
    my $self = shift;
    my @cfg_files = @_;
    unless (scalar @cfg_files) { croak "cfg_file: must have at least one config file." }
    $self->{__CFG_FILES} = \@cfg_files;
}


1;
__END__

=pod

=head1 Example Perl config file

Here's a simple example Perl config file.  Be sure that your last statement
returns a hash reference.

    my %CFG = ();

    # directory path name
    $CFG{ROOT_DIR} = '/home/mark/www';

    # website URL
    $CFG{ROOT_URL} = 'http://mark.stosberg.com/';

    \%CFG;

=head1 SEE ALSO

L<CGI::Application|CGI::Application>
L<CGI::Application::Plugin::ValidateRM|CGI::Application::Plugin::ValidateRM>
L<CGI::Application::Plugin::DBH|CGI::Application::Plugin::DBH>
L<CGI::Application::Standard::Config|CGI::Application::Standard::Config>.
perl(1)

=head1 AUTHOR

Mark Stosberg <mark@summersault.com>

=head1 LICENSE

Copyright (C) 2010 Mark Stosberg <mark@summersault.com>

This library is free software. You can modify and or distribute it under the
same terms as Perl itself.

=cut

