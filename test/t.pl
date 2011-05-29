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
print "error cdr url\n" if ($tc->confCdr('xml', 'url') ne 'http://example.com/cdr/');
print "error cdr cred\n" if ($tc->confCdr('xml', 'cred') ne 'test:test');
print "error cdr auth-scheme\n" if ($tc->confCdr('xml', 'auth-scheme') ne 'basic');
print "error cdr encode\n" if ($tc->confCdr('xml', 'encode') ne 'true');
print "error cdr retries\n" if ($tc->confCdr('xml', 'retries') ne '5');
print "error cdr delay\n" if ($tc->confCdr('xml', 'delay') ne '10');
print "error cdr err-log-dir\n" if ($tc->confCdr('xml', 'err-log-dir') ne '/opt/freeswitch/log/xml_cdr');
print "error cdr log-b-leg\n" if ($tc->confCdr('xml', 'log-b-leg') ne 'false');
print "error cdr prefix-a-leg\n" if ($tc->confCdr('xml', 'prefix-a-leg') ne 'true');
#print "error cdr \n" if ($tc->confCdr('') ne '');

