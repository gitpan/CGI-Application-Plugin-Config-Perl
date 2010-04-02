use Test::More 'no_plan';

use CGI::Application::Plugin::Config::Perl;

use lib './t';
use strict;

$ENV{CGI_APP_RETURN_ONLY} = 1;

use TestAppBasic;
my $t1_obj = TestAppBasic->new;
eval { $t1_obj->cfg_file('t/empty_config.pl');
       $t1_obj->cfg;
};

like ($@, qr/\QNo configuration found/);

