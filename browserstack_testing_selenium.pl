#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Selenium::Remote::Driver;

#Input capabilities
#my $extraCaps = { 
#  "browser" => "IE",
#    "browser_version" => "8.0",
#      "os" => "Windows",
#        "os_version" => "7",
#          "browserstack.debug" => "true"
#          };

my %extraCaps_desktop = (
'IE11' => { 
"browser" => "IE",
"browser_version" => "11.0",
"os" => "Windows",
"os_version" => "8.1",
"resolution" => "1024x768",
"browserstack.debug" => "true"
},
'FF35' => { 
"browser" => "Firefox",
"browser_version" => "35.0",
"os" => "Windows",
"os_version" => "8.1",
"resolution" => "1024x768",
"browserstack.debug" => "true"
},
'Chrome39' => { 
"browser" => "Chrome",
"browser_version" => "39.0",
"os" => "Windows",
"os_version" => "8.1",
"resolution" => "1024x768",
"browserstack.debug" => "true"
},
'IE10' => { 
"browser" => "IE",
"browser_version" => "10.0",
"os" => "Windows",
"os_version" => "7",
"resolution" => "1024x768",
"browserstack.debug" => "true"
},
'IE9' => { 
"browser" => "IE",
"browser_version" => "9.0",
"os" => "Windows",
"os_version" => "7",
"resolution" => "1024x768",
"browserstack.debug" => "true"
},
'Safari8' => { 
"browser" => "Safari",
"browser_version" => "8.0",
"os" => "OS X",
"os_version" => "Yosemite",
"resolution" => "1024x768",
"browserstack.debug" => "true"
}
          );



my %extraCaps_mobile = (
                 'iPhone5_iOS6_1' => {
                                      "platform" => "MAC",
                                      "browserName" => "iPhone",
                                      "device" => "iPhone 5",
                                      "browserstack.debug" => "true"
                                     },
                 'iPhone5C_iOS7' =>  {
                                      "platform" => "MAC",
                                      "browserName" => "iPhone",
                                      "device" => "iPhone 5C",
                                      "browserstack.debug" => "true"
                                     },
                 'iPhone5S_iOS7'  => {
                                      "platform" => "MAC",
                                      "browserName" => "iPhone",
                                      "device" => "iPhone 5S",
                                      "browserstack.debug" => "true"
                                     },

                 'GalaxyS4_4_3'   => {
                                      "browserName" => "android",
                                      "platform" => "ANDROID",
                                      "device" => "Samsung Galaxy S4",
                                      "browserstack.debug" => "true"
                                     },

                 'GalaxyS5_4_4'   => {
                                      "browserName" => "android",
                                      "platform" => "ANDROID",
                                      "device" => "Samsung Galaxy S5",
                                      "browserstack.debug" => "true"
                                     },

                 'Nexus5_5'       => {
                                      "browserName" => "android",
                                      "platform" => "ANDROID",
                                      "device" => "Google Nexus 5",
                                      "browserstack.debug" => "true"
                                     }
                );







my $login = "";
my $key = "";
my $host = "$login:$key\@hub.browserstack.com";


my $extraCaps_platform=\%extraCaps_desktop;

foreach my $devices (sort keys % {$extraCaps_platform} ){

#print \%{$extraCaps{$devices}}."\n";

my $driver = new Selenium::Remote::Driver('remote_server_addr' => $host, 
                                          'port' => '80', 'extra_capabilities' => ${$extraCaps_platform}{$devices});
$driver->debug_on;

#my $driver = new Selenium::Remote::Driver('remote_server_addr' => $host, 
#                                         'port' => '80', 'extra_capabilities' => $extraCaps);
ok( $driver->get('http://www.google.com'), "Load www.google.com" );
ok( $driver->find_element('q','name')->send_keys("BrowserStack"), "Search for BrowserStack" );
ok( $driver->get_title eq "Google", "Going to get title of page - Google" );

$driver->quit();
}
done_testing();

