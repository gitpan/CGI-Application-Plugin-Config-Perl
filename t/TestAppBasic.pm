package TestAppBasic;

use strict;

use base 'CGI::Application';

use CGI::Application::Plugin::Config::Perl qw(cfg cfg_file);

sub setup {
    my $self = shift;

    $self->start_mode('test_mode');

    $self->run_modes(test_mode => 'test_mode' );
}

sub test_mode {
  my $self = shift;
  return 1;
}


1;
