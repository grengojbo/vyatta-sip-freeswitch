#!/usr/bin/perl

use lib "/opt/vyatta/share/perl5/";
#use Vyatta::Config;
#use Vyatta::Interface;
#use Vyatta::FreeSWITCH::Config;
use Vyatta::FreeSWITCH::TestConfig;

use Getopt::Long;
use POSIX;

use strict;
use warnings;

my $tc = new Vyatta::FreeSWITCH::TestConfig;
#$tc->setup();

#my @modules_cdr = ('xml', 'csv', 'sqlite', 'postgresql', 'json', 'radius');
my @modules_cdr = ('xml_cdr', 'cdr_csv', 'radius_cdr');
#my @modules_cdr = ('xml_cdr', 'cdr_csv');
for my $rem (@modules_cdr) {
    print "No module load mod_$rem\n" if (!defined($tc->confModules($rem)));
}
print "No module load lua\n" if (!defined($tc->confModules('lua')));

