use Test::More 'no_plan';

use CGI::Application::Plugin::Config::Perl;

use lib './t';
use strict;

$ENV{CGI_APP_RETURN_ONLY} = 1;

use TestAppBasic;
my $t1_obj = TestAppBasic->new;
   $t1_obj->cfg_file('t/basic_config.pl','t/empty_config.pl');
my $t1_output = $t1_obj->run;

is($t1_obj->config('test_key_1'),11,'config(), accessing a field directly');

ok($t1_obj->std_config, 'std_config() is present');

my %cfg = $t1_obj->cfg;

is($cfg{test_key_2},22,'cfg(), returning whole hash');

my $href = $t1_obj->cfg;

is($href->{test_key_2},22,'cfg(), returning hashref');

is($t1_obj->cfg->{test_key_2},22,'cfg(), accessing hash key directly via hashref');


