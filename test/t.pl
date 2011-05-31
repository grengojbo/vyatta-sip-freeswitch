#!/usr/bin/perl

use lib "/opt/vyatta/share/perl5/";
#use Vyatta::Config;
#use Vyatta::Interface;
#use Vyatta::FreeSWITCH::Config;
use Vyatta::FreeSWITCH::TestConfig;

use Getopt::Long;
use POSIX;
use Config::IniFiles;

use strict;
use warnings;

my $tc = new Vyatta::FreeSWITCH::TestConfig;
#$tc->setup();
my @modules_cdr = ('xml_cdr', 'cdr_csv', 'radius_cdr');

my ($profile_name, $user_name, $conf_name);
sub usage {
    print <<EOF;
Usage: $0 --conf=<conf_name>
       $0 --profile=<name_profile> [--gateway=<name_gateway>] [--action=<create|update|delete>] [--update|--delete|-create=<var_name>]
       $0 --user=<name_user>
EOF
    exit 1;
}

GetOptions("conf=s"  => \$conf_name,
       "profile=s"	       => \$profile_name,
       "user=s"	       => \$user_name,
) or usage();

fs_conf($conf_name) if ($conf_name);
exit 0;

sub fs_conf {
my $name = shift;
if ($name eq 'modules') {
    for my $rem (@modules_cdr) {
        print "No module load mod_$rem\n" if (!defined($tc->confModules($rem)));
    }
    print "No module load lua\n" if (!defined($tc->confModules('lua')));
}
elsif ($name eq 'cdr') {
    #my @modules_cdr = ('xml', 'csv', 'sqlite', 'postgresql', 'json', 'radius');
    #my @modules_cdr = ('xml_cdr', 'cdr_csv');
    print "error cdr url\n" if ($tc->confCdr('xml', 'url') ne 'http://example.com/cdr/');
    print "error cdr cred\n" if ($tc->confCdr('xml', 'cred') ne 'test:test');
    print "error cdr auth-scheme\n" if ($tc->confCdr('xml', 'auth-scheme') ne 'basic');
    print "error cdr encode\n" if ($tc->confCdr('xml', 'encode') ne 'true');
    print "error cdr retries\n" if ($tc->confCdr('xml', 'retries') ne '5');
    print "error cdr delay\n" if ($tc->confCdr('xml', 'delay') ne '10');
    print "error cdr err-log-dir\n" if ($tc->confCdr('xml', 'err-log-dir') ne '/opt/freeswitch/log/xml_cdr');
    print "error cdr log-b-leg\n" if ($tc->confCdr('xml', 'log-b-leg') ne 'false');
    print "error cdr prefix-a-leg\n" if ($tc->confCdr('xml', 'prefix-a-leg') ne 'true');
}
elsif ($name eq 'acl') {
    print "error acl default\n" if ($tc->confAcl('mylan', 'default') ne 'deny');
    print "error acl 1\n" if ($tc->confAcl('mylan', '192.168.10.0/24') ne 'allow');
    print "error acl 2\n" if ($tc->confAcl('mylan', '192.168.10.20/32') ne 'deny');
    print "error acl 3\n" if ($tc->confAcl('mylan', '192.168.20.0/24') ne 'deny');
}
elsif ($name eq 'db') {
    print "error db default\n" if ($tc->confDB('testdb', 'testdb:test:test') ne 'testdb:test:test');
}
elsif ($name eq 'cli') {
    print "error cli nat-map\n" if ($tc->confCli('nat-map') ne 'false');
    print "error cli listen-ip\n" if ($tc->confCli('listen-ip') ne '127.0.0.1');
    print "error cli listen-port\n" if ($tc->confCli('listen-port') ne '5021');
    print "error cli password\n" if ($tc->confCli('password') ne '123');
    print "error cli acl\n" if ($tc->confCli('acl') ne 'lans');
}
elsif ($name eq 'odbc') {
    my $fs_dir = '/opt/freeswitch';
    my $fs_odbc = $fs_dir.'/.odbc.ini';

    #my $cfg = Config::IniFiles->new(-file => $fs_odbc, -default => "ODBC Data Sources" );
    my ($cfg);
    my $sec = 'testdb';
    if (-e $fs_odbc) {
        $cfg = Config::IniFiles->new(-file => $fs_odbc);
        print "error odbc PORT\n" if ($cfg->val($sec, "PORT") ne '3306');
        print "error odbc DATABASE\n" if ($cfg->val($sec, 'DATABASE') ne 'testdb');
        print "error odbc SERVER\n" if ($cfg->val($sec, 'SERVER') ne 'localhost');
        print "error odbc PASSWORD\n" if ($cfg->val($sec, 'PASSWORD') ne 'test');
        print "error odbc USER\n" if ($cfg->val($sec, 'USER') ne 'test');
        print "error odbc OPTION\n" if ($cfg->val($sec, 'OPTION') ne '67108864');
        print "error odbc Driver\n" if ($cfg->val($sec, 'Driver') ne 'MySQL');
        #print "error odbc \n" if ($cfg->val($sec, '') ne '');
    }
    else {
        print "error odbc $fs_odbc";
    }
    #if ($cfg->exists($sec, 'PORT') $cfg->val($sec, "PORT", "3306")) {
}
}
