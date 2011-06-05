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
elsif ($name eq 'profile') {
    my $profile_name = 'test_external';
    my $profile_ip = '10.10.10.10';
    print "error profile $profile_name name\n" if ($tc->confProfile($profile_name, $profile_name, 'name') ne $profile_name);
    print "error profile $profile_name debug\n" if ($tc->confProfile($profile_name, 'debug', 'param') ne '0');
    print "error profile $profile_name sip-trace\n" if ($tc->confProfile($profile_name, 'sip-trace', 'param') ne 'no');
    print "error profile $profile_name rfc2833-pt\n" if ($tc->confProfile($profile_name, 'rfc2833-pt', 'param') ne '101');
    print "error profile $profile_name sip-port\n" if ($tc->confProfile($profile_name, 'sip-port', 'param') ne '5060');
    print "error profile $profile_name dialplan\n" if ($tc->confProfile($profile_name, 'dialplan', 'param') ne 'XML');
    print "error profile $profile_name context\n" if ($tc->confProfile($profile_name, 'context', 'param') ne 'public');
    print "error profile $profile_name dtmf-duration\n" if ($tc->confProfile($profile_name, 'dtmf-duration', 'param') ne '2000');
    print "error profile $profile_name inbound-codec-prefs\n" if ($tc->confProfile($profile_name, 'inbound-codec-prefs', 'param') ne 'PCMA');
    print "error profile $profile_name outbound-codec-prefs\n" if ($tc->confProfile($profile_name, 'outbound-codec-prefs', 'param') ne 'PCMA');
    print "error profile $profile_name rtp-timer-name\n" if ($tc->confProfile($profile_name, 'rtp-timer-name', 'param') ne 'soft');
    print "error profile $profile_name manage-presence\n" if ($tc->confProfile($profile_name, 'manage-presence', 'param') ne 'false');
    print "error profile $profile_name inbound-codec-negotiation\n" if ($tc->confProfile($profile_name, 'inbound-codec-negotiation', 'param') ne 'generous');
    print "error profile $profile_name nonce-ttl\n" if ($tc->confProfile($profile_name, 'nonce-ttl', 'param') ne '60');
    print "error profile $profile_name auth-calls\n" if ($tc->confProfile($profile_name, 'auth-calls', 'param') ne 'false');
    print "error profile $profile_name rtp-ip\n" if ($tc->confProfile($profile_name, 'rtp-ip', 'param') ne $profile_ip);
    print "error profile $profile_name sip-ip\n" if ($tc->confProfile($profile_name, 'sip-ip', 'param') ne $profile_ip);
    print "error profile $profile_name ext-rtp-ip\n" if ($tc->confProfile($profile_name, 'ext-rtp-ip', 'param') ne $profile_ip);
    print "error profile $profile_name ext-sip-ip\n" if ($tc->confProfile($profile_name, 'ext-sip-ip', 'param') ne $profile_ip);
    print "error profile $profile_name rtp-timeout-sec\n" if ($tc->confProfile($profile_name, 'rtp-timeout-sec', 'param') ne '300');
    print "error profile $profile_name rtp-hold-timeout-sec\n" if ($tc->confProfile($profile_name, 'rtp-hold-timeout-sec', 'param') ne '1800');
    print "error profile $profile_name disable-transcoding\n" if ($tc->confProfile($profile_name, 'disable-transcoding', 'param') ne 'false');


    $profile_name = 'test_internal';
    $profile_ip = '192.168.67.67';
    print "error profile $profile_name context\n" if ($tc->confProfile($profile_name, 'context', 'param') ne 'default');
    print "error profile $profile_name auth-calls\n" if ($tc->confProfile($profile_name, 'auth-calls', 'param') ne 'true');
    print "error profile $profile_name rtp-ip\n" if ($tc->confProfile($profile_name, 'rtp-ip', 'param') ne $profile_ip);
    print "error profile $profile_name sip-ip\n" if ($tc->confProfile($profile_name, 'sip-ip', 'param') ne $profile_ip);
    print "error profile $profile_name ext-rtp-ip\n" if ($tc->confProfile($profile_name, 'ext-rtp-ip', 'param') ne $profile_ip);
    print "error profile $profile_name ext-sip-ip\n" if ($tc->confProfile($profile_name, 'ext-sip-ip', 'param') ne $profile_ip);
    print "error profile $profile_name outbound-codec-prefs\n" if ($tc->confProfile($profile_name, 'outbound-codec-prefs', 'param') ne 'PCMA,speex@16000h@20i,speex@32000h@20i,speex@8000h@20i');

    print "error profile $profile_name \n" if ($tc->confProfile($profile_name, 'bitpacking', 'param') ne 'aal2');
    print "error profile $profile_name inbound-codec-negotiation\n" if ($tc->confProfile($profile_name, 'inbound-codec-negotiation', 'param') ne 'greedy');
    print "error profile $profile_name disable-transcoding\n" if ($tc->confProfile($profile_name, 'disable-transcoding', 'param') ne 'true');
    print "error profile $profile_name inbound-late-negotiation\n" if ($tc->confProfile($profile_name, 'inbound-late-negotiation', 'param') ne 'true');
    print "error profile $profile_name auth-all-packets\n" if ($tc->confProfile($profile_name, 'auth-all-packets', 'param') ne 'false');
    #print "error profile $profile_name \n" if ($tc->confProfile($profile_name, '', 'param') ne '');
    #print "error profile $profile_name \n" if ($tc->confProfile($profile_name, '', 'param') ne '');
    #print "error profile $profile_name \n" if ($tc->confProfile($profile_name, '', 'param') ne '');
}
elsif ($name eq 'gateway') {
    print "error gateway name\n" if ($tc->confGateway('external', 'voip-provider', '', 'name') ne 'voip-provider');
    print "error gateway realm\n" if ($tc->confGateway('external', 'voip-provider', 'realm', 'param') ne 'sip.089.com.ua');
    print "error gateway username\n" if ($tc->confGateway('external', 'voip-provider', 'username', 'param') ne 'pass');
    print "error gateway password\n" if ($tc->confGateway('external', 'voip-provider', 'password', 'param') ne 'pass');
    print "error gateway from-domain\n" if ($tc->confGateway('external', 'voip-provider', 'from-domain', 'param') ne '192.168.123.36');
    print "error gateway register\n" if ($tc->confGateway('external', 'voip-provider', 'register', 'param') ne 'false');
    print "error gateway register-transport\n" if ($tc->confGateway('external', 'voip-provider', 'register-transport', 'param') ne 'udp');
    print "error gateway retry-seconds\n" if ($tc->confGateway('external', 'voip-provider', 'retry-seconds', 'param') ne '90');
    print "error gateway caller-id-in-from\n" if ($tc->confGateway('external', 'voip-provider', 'caller-id-in-from', 'param') ne 'true');
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
