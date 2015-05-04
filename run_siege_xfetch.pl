#!/usr/bin/perl

use strict;
use warnings;

use IO::File;
use Test::Simple tests => 2;

use Data::Dumper;

my $xfetch_server="http://xfetch01.ds.qa.corp.oversee.net:7003/";
my $xfetch_request="xfetch?pl=adk1_cpv,(admkt_kws;admkt1oo_cpv),(zeropark_kws;zeropark1_cpv)&q=umm_test_keyword&q_umm=Hot%20Tub&ip=75.84.43.216&p1=Mozilla%2F5.0%20%28Windows%20NT%206.1%3B%20WOW64%3B%20rv%3A34.0%29%20Gecko%2F20100101%20Firefox%2F34.0&domainname=spa8.com&encrypted_domainname=666";

my $siege_command="siege -t 15S";
my $siege_output="/home/akukenas/siege_xfetch_cpv_output.txt";
my $siege_results="/home/akukenas/siege_xfetch_cpv_results.txt";
my %siege_results=();
my ($key, $value);
my @siege_output_line;

#siege -t 10S -i -c20 "http://xfetch01.ds.qa.corp.oversee.net:7003/xfetch?pl=adk1_cpv,(admkt_kws;admkt1oo_cpv),(zeropark_kws;zeropark1_cpv)&q=umm_test_keyword&q_umm=Hot%20Tub&ip=75.84.43.216&p1=Mozilla%2F5.0%20%28Windows%20NT%206.1%3B%20WOW64%3B%20rv%3A34.0%29%20Gecko%2F20100101%20Firefox%2F34.0&domainname=spa8.com&encrypted_domainname=666" > siege_xfetch_cpv_test.txt 2> siege_output.txt

system("$siege_command \"$xfetch_server$xfetch_request\" > $siege_output 2> $siege_results");


open(SR, $siege_results);

while(<SR>){
  if (/:/){
    ($key,$value)=split(":",$_);
    chomp($key);
    $value=~s/\s+//;
    chomp($value);
    $siege_results{$key}=$value;
  }
}
close SR;

#open(SO, $siege_output);
#
#while(<SO>){
#@siege_output_line=split(",",$_);
#print "@siege_output_line[0,2,3,4]\n";
#}
#
#close SO;

#print Dumper(\%siege_results);

#foreach (keys %siege_results){
#
#if ($_ eq "Availability"){
#  ok ( $siege_results{$_} =~ "100.00","Checking for 100 percent availability");
#} else {
#    print $_.": ".$siege_results{$_}."\n"
#}
#
#}

ok ( $siege_results{"Availability"} eq "100.00 %","Checking for 100 percent availability (expecting 100.00 %)");
ok ( $siege_results{"Failed transactions"} == "0","Checking for any failed Transactions (expecting 0)");


foreach (keys %siege_results){
  print $_.": ".$siege_results{$_}."\n";
}

exit 0;
