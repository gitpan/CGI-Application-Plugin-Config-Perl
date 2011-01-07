use Test::More 'no_plan';

use CGI::Application::Plugin::Config::Perl;

use lib './t';
use strict;

$ENV{CGI_APP_RETURN_ONLY} = 1;

use TestAppBasic;
TestAppBasic->cfg_file('t/basic_config.pl','t/empty_config.pl');
my $t1_obj = TestAppBasic->new;
my $t1_output = $t1_obj->run;

is($t1_obj->config('test_key_1'),11,'config(), accessing a field directly');

# Run a second time to test the persistent behavior.
# By adding a "warn" to Config.pl, you can manually check how many times the config file has been read.
TestAppBasic->cfg_file('t/basic_config.pl','t/empty_config.pl');
$t1_obj = TestAppBasic->new;
$t1_output = $t1_obj->run;
is($t1_obj->config('test_key_1'),11,'config(), accessing a field directly');
