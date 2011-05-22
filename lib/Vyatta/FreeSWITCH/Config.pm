# **** License ****
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# This code was originally developed by Vyatta, Inc.
# Portions created by Vyatta are Copyright (C) 2007 Vyatta, Inc.
# All Rights Reserved.
#
# **** End License ****

package Vyatta::FreeSWITCH::Config;
use strict;
use lib "/opt/vyatta/share/perl5/";
use Vyatta::Config;
use Vyatta::TypeChecker;
use NetAddr::IP;

use XML::Simple;
use Data::Dumper;

my $fs_dir = '/opt/freeswitch';
my $fs_conf_dir = '/opt/freeswitch/conf';
my $fs_fs = $fs_conf_dir.'/freeswitch.xml';
my $fs_modules = $fs_conf_dir.'/autoload_configs/modules.conf.xml';
my $fs_switch = $fs_conf_dir.'/autoload_configs/switch.conf.xml';
my $fs_event_socket = $fs_conf_dir.'/autoload_configs/event_socket.conf.xml';
#my $status_dir = '/opt/vyatta/etc/openvpn/status';
#my $status_itvl = 30;
#my $ping_itvl = 10;
#my $ping_restart = 60;

my %fields = (
  _areacode     => undef,
  _country      => undef,
  _domain_name  => undef,
  _description  => undef,
  _dump_cores   => undef,
  _cli   => undef,
  _cli_port   => undef,
  _cli_address   => undef,
  _cli_nat   => undef,
  _cli_password   => undef,
  #_cli_acl   => undef,
  _codecs      => [],
  _profile      => [],
  _user         => [],
  _language     => [],
  _loglevel     => undef,
  _max_sessions => undef,
  _mode         => undef,
  _modules      => [],
  _zrtp_secure_media      => undef,
  _default_language       => undef,
  _multiple_registrations => undef,
  _sessions_per_second    => undef,
  _tls_ca        => undef,
  _tls_cert      => undef,
  _tls_key       => undef,
  _tls_dh        => undef,
  _tls_crl       => undef,
  _tls_role      => undef,
  _is_empty      => 1,
);
my @languages_all = ('en', 'ru', 'de', 'es', 'fr', 'he', 'it', 'hl');
#TODO: celt
my @codecs_all = ('pcma', 'speex', 'pcmu', 'ilbc', 'g729', 'g723', 'amr', 'g722', 'gsm', 'g726', 'h263', 'h263-1998', 'h264');
my %global_codecs_hash = (                                                                                                                               
    'g723' => 'G723',
    'g729' => 'G729',
    'amr' => 'AMR',
    'ilbc' => 'iLBC@20i',
    'speex' => 'speex@16000h@20i,speex@32000h@20i,speex@8000h@20i',
    'pcma' => 'PCMA',
    'pcmu' => 'PCMU',
    'g722' => 'G7221@16000h,G7221@32000h',
    'gsm' => 'GSM',
    'g726' => 'G726-24,G726-16',
    'h263' => 'H263',
    'h263-1998' => 'H263-1998',
    'h263' => 'H264',
    'celt' => 'CELT@32000h,CELT@48000h',
);

my %modules_codecs_hash = (
    'g723' =>'mod_g723_1',
    'g729' =>'mod_g729',
    'amr' =>'mod_amr',
    'ilbc' =>'mod_ilbc',
    'speex' =>'mod_speex',
    'video' =>'mod_h26x',
    'g722' =>'mod_siren',
    #<!--<'' =>'mod_celt',-->
    #<!--<'' =>'mod_opus',-->
);

my @modules_unsuport = ('voicemail', 'xml_cdr', 'curl', 'conference', 'perl', 'python', 'billing', 'enum', 'rpc', 'event-multicast', 'dingaling', 'portaudio', 'skinny', 'directory', 'distributor', 'lcr', 'spy', 'snom',   'dialplan-directory', 'dialplan-asterisk', 'shout', 'spidermonkey', 'flite', 'tts-commandline', 'rss', 'fifo'); 
my %modules_cmd_hash = (
    'voicemail' =>'mod_voicemail',
    'xml_cdr' =>'mod_xml_cdr',
    #<!--<'' =>'mod_cdr_csv',
    #<!-- <'' =>'mod_cdr_sqlite',
    'cli' =>'mod_event_socket',
    'curl' =>'mod_xml_curl',
    'conference' =>'mod_conference',
    'fifo' =>'mod_fifo',
    #<'' =>'mod_cluechoo',
    'perl' =>'mod_perl',
    'python' =>'mod_python',
    'billing' =>'mod_nibblebill',
    #<!--<'' =>'mod_logfile"
    #<!-- <'' =>'mod_syslog"
    #<!--<'' =>'mod_yaml"
    #<!-- Multi-Faceted -->
    #<!-- mod_enum is a dialplan interface, an application interface and an api command interface -->
    'enum' =>'mod_enum',
    #<!-- XML Interfaces -->
    'rcp' =>'mod_xml_rpc',
    #<!-- Event Handlers -->
    'event-multicast' =>'mod_event_multicast',
    #<!-- <'' =>'mod_event_zmq',
    #<!-- <'' =>'mod_zeroconf',
    #<!-- <'' =>'mod_erlang_event',
    #<!-- <'' =>'mod_snmp',
    #<!-- Directory Interfaces
    #<!-- <'' =>'mod_ldap',
    #<!-- Endpoints -->
    'dingaling' =>'mod_dingaling',
    'portaudio' =>'mod_portaudio',
    #<!-- <'' =>'mod_alsa',
    #<!-- <'' =>'mod_woomera',
    #<!-- <'' =>'mod_freetdm',
    #<!-- <'' =>'mod_openzap',
    #<!-- <'' =>'mod_unicall',
    'skinny' =>'mod_skinny',
    #<!-- <'' =>'mod_khomp',
    #<!-- Applications -->
    'directory' =>'mod_directory',
    'distributor' =>'mod_distributor',
    'lcr' =>'mod_lcr',
    #<!--<'' =>'mod_fsk',
    'spy' =>'mod_spy',
    #<!-- SNOM Module -->
    'snom' =>'mod_snom',
    #<!-- This one only works on Linux for now -->
    #<!--<'' =>'mod_ladspa',
    #<!-- Dialplan Interfaces -->
    'dialplan-directory' =>'mod_dialplan_directory',
    'dialplan-asterisk' =>'mod_dialplan_asterisk',
    #<!-- File Format Interfaces
    #<!--For icecast/mp3 streams/files
    'shout' =>'mod_shout',
    #<!-- Languages -->
    #<!--<'' =>'mod_spidermonkey',
    #<!-- <'' =>'mod_java',
    #<!-- ASR /TTS -
    'flite' =>'mod_flite',
    #<!-- <'' =>'mod_pocketsphinx',
    #<!-- <'' =>'mod_cepstral',
    'tts-commandline' =>'mod_tts_commandline',
    'rss' =>'mod_rss',
);

my $fsLevel = 'service sip';

sub new {
  my $that = shift;
  my $class = ref ($that) || $that;
  my $self = {
    %fields,
  };

  bless $self, $class;
  return $self;
}

sub setup {
  my $self = shift;
  my $config = new Vyatta::Config;

  # set up ccd for this interface
  $config->setLevel("$fsLevel");
  my @nodes = $config->listNodes();
  if (scalar(@nodes) <= 0) {
    $self->{_is_empty} = 1;
    return 0;
  } else {
    $self->{_is_empty} = 0;
  }
  
  #$self->{_intf} = $intf;
  $self->{_areacode} = $config->returnValue('areacode');
  $self->{_country} = $config->returnValue('country');
  $self->{_default_language} = $config->returnValue('default-language');
  $self->{_description} = $config->returnValue('description');
  $self->{_domain_name} = $config->returnValue('domain-name');
  $self->{_dump_cores} = $config->returnValue('dump-cores');
  $self->{_cli_address} = $config->returnValue('cli listen-address');
  $self->{_cli_port} = $config->returnValue('cli listen-port');
  $self->{_cli_nat} = $config->returnValue('cli nat');
  $self->{_cli_password} = $config->returnValue('cli password');
  #$self->{_cli_acl} = $config->returnValue('cli acl');
  $self->{_cli} = (defined($self->{_cli_password})
                       || defined($self->{_cli_address})
                       || defined($self->{_cli_port})) ? 1 : undef;
  my @tmp_language = $config->returnValues('language');
  $self->{_language} = \@tmp_language;
  my @tmp_codecs = $config->returnValues('codecs');
  $self->{_codecs} = \@tmp_codecs;
  $self->{_loglevel} = $config->returnValue('loglevel');
  $self->{_max_sessions} = $config->returnValue('max-sessions');
  $self->{_mode} = $config->returnValue('mode');
  my @tmp_modules = $config->returnValues('modules');
  $self->{_modules} = \@tmp_modules;
  $self->{_multiple_registrations} = $config->returnValue('multiple-registrations');
  my @tmp_profile = $config->returnValues('profile');
  $self->{_profile} = \@tmp_profile;
  $self->{_sessions_per_second} = $config->returnValue('sessions-per-second');
  $self->{_zrtp_secure_media} = $config->returnValue('zrtp-secure-media');
  my @tmp_user = $config->returnValues('_user');
  $self->{_user} = \@tmp_user;
  #$self->{_options} = $config->returnValue('openvpn-option');
  #$self->{_secret_file} = $config->returnValue('shared-secret-key-file');
  #$self->{_server_subnet} = $config->returnValue('server subnet');
  #$self->{_server_def} = (defined($self->{_server_subnet})) ? 1 : undef;
  return 0;
}

sub get_command {
  my ($self) = @_;
  my $cmd = "/etc/init.d/freeswitch restart"; 
  #if ( $self->{_disable} ) { return ('disable', undef); }

  # status
  #$cmd .= " --status $status_dir/$self->{_intf}.status $status_itvl";
 
  # interface
  #my $type = 'tun';
  #if ( $self->{_bridge} ) { $type = 'tap'; }
  #else { $type = 'tun'; }
  #$cmd .= " --dev-type $type --dev $self->{_intf}";

  #my ($tcp_p, $tcp_a) = (0, 0);
  #if (defined($self->{_proto})) {
  #  if ($self->{_proto} eq 'tcp-passive') {
  #    $tcp_p = 1;
  #  } elsif ($self->{_proto} eq 'tcp-active') {
  #    $tcp_a = 1;
  #  }
  #}

  # mode
  #my ($client, $server, $topo) = (0, 0, 'subnet');
  return (undef, 'Must specify "mode"') if (!defined($self->{_mode}));
  return (undef, 'Must specify "language"') if (scalar(@{$self->{_language}}) == 0);
  return (undef, 'Must specify "default-language"') if (!defined($self->{_default_language}));
  return (undef, 'Must specify "codecs"') if (scalar(@{$self->{_codecs}}) == 0);
  if (defined($self->{_cli})) {
    return (undef, 'Must specify "set service sip cli password"') if (!defined($self->{_cli_password}));
    return (undef, 'Must specify "set service sip cli listen-port"') if (!defined($self->{_cli_port}));
    return (undef, 'Must specify "set service sip cli listen-address"') if (!defined($self->{_cli_address}));
  }
  return ($cmd, undef);
}

sub isEmpty {
  my ($self) = @_;
  return $self->{_is_empty};
}

sub confLanguage {
    my ($self) = @_;
    if (scalar(@{$self->{_language}}) > 0) {
        my $fs_config = XMLin($fs_fs);
        delete $fs_config->{section}->{languages};
        for my $rem (@{$self->{_language}}) {
            push @{ $fs_config->{section}->{languages}->{'X-PRE-PROCESS'} }, { cmd => 'include', data => "lang/$rem/*.xml" };
        }
        $fs_config->{section}->{languages}->{description}="Language Management";
        my $fs_config_new = XML::Simple->new(rootname=>'document');
        open my $fh, '>:encoding(UTF-8)', $fs_fs or die "open($fs_fs): $!";
        $fs_config_new->XMLout($fs_config, OutputFile => $fh);
    }
    print "exec confLanguage\n";
}

sub confModules {
    my ($self) = @_;
    my $fs_config = XMLin($fs_modules);
    delete $fs_config->{modules};
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_console' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_sofia' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_loopback' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_commands' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_db' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_dptools' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_expr' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_hash' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_esf' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_fsv' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_valet_parking' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_dialplan_xml' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_spandsp' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_sndfile' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_native_file' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_local_stream' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_tone_stream' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_timerfd' };
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_event_socket' } if (defined($self->{_cli}));
    my $is_key = 0;
    if (scalar(@{$self->{_codecs}}) > 0) {
        foreach my $key (@{$self->{_codecs}}) {
            if ($key eq 'h263' || $key eq 'h263-1998' || $key eq 'h264') {
                if ($is_key == 0) {
                    push @{ $fs_config->{modules}->{load} }, { module => $modules_codecs_hash{video} };
                    $is_key = 1;
                }
            }
            elsif ($key ne 'pcma' && $key ne 'pcmu' && $key ne 'gsm' && $key ne 'g726') {
                push @{ $fs_config->{modules}->{load} }, { module => $modules_codecs_hash{$key} };
            }
        }
    }
    if (scalar(@{$self->{_language}}) > 0) {
        for my $rem (@{$self->{_language}}) {
            push @{ $fs_config->{modules}->{load} }, { 'module' => "mod_say_$rem" };
        }
    }
    if (scalar(@{$self->{_modules}}) > 0) {
        for my $rem (@{$self->{_modules}}) {
            push @{ $fs_config->{modules}->{load} }, { 'module' => $modules_cmd_hash{$rem} };
        }
    }
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_lua' };
    
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_modules or die "open($fs_modules): $!";
    $fs_config_new->XMLout($fs_config, OutputFile => $fh);
    print "exec confModules\n";
}

sub confCli {
    my ($self) = @_;
    my $fs_config = XMLin($fs_event_socket, KeyAttr=>{});
    foreach my $fs (@{$fs_config->{settings}->{param}}) {
        if ($fs->{name} eq 'nat-map' && defined($self->{_cli_nat})) {
            $fs->{value} = $self->{_cli_nat};
        }
        elsif ($fs->{name} eq 'listen-ip' && defined($self->{_cli_address})) {
            $fs->{value} = $self->{_cli_address};
        }
        elsif ($fs->{name} eq 'listen-port' && defined($self->{_cli_port})) {
            $fs->{value} = $self->{_cli_port};
        }
        elsif ($fs->{name} eq 'password' && defined($self->{_cli_password})) {
            $fs->{value} = $self->{_cli_password};
        }
    }
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_event_socket or die "open($fs_event_socket): $!";
    $fs_config_new->XMLout($fs_config, OutputFile => $fh);
    print "exec confCli\n";
}
sub confSwitch {
    my ($self) = @_;
    my $fs_config = XMLin($fs_switch, KeyAttr=>{params=>"+names"});
    foreach my $key (@{$fs_config->{settings}->{param}}) {
        if ($key->{name} eq 'dump-cores') {
            $key->{value}=$self->{_dump_cores};
        }
        elsif ($key->{name} eq 'loglevel') {
            $key->{value}=$self->{_loglevel};
        }
        elsif ($key->{name} eq 'max-sessions') {
            $key->{value}=$self->{_max_sessions};
        }
        elsif ($key->{name} eq 'sessions-per-second') {
            $key->{value}=$self->{_sessions_per_second};
        }
        elsif ($key->{name} eq 'rtp-enable-zrtp') {
            $key->{value}=$self->{_zrtp_secure_media};
        }
        
    }
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_switch or die "open($fs_switch): $!";
    $fs_config_new->XMLout($fs_config, OutputFile=>$fh);
    #print $fs_config_new->XMLout($fs_config, xmldecl=>'<?xml version="1.0">');
    print "exec confSwitch\n";
}

sub show_modules {
    print join(' ', @modules_unsuport), "\n";
}

sub show_languages {
    print join(' ', @languages_all), "\n";
}

sub show_codecs {
    print join(' ', @codecs_all), "\n";
}

sub showLanguage {
    my ($self) = @_;
  if (scalar(@{$self->{_language}}) > 0) {
      return (join(' ', @{$self->{_language}}), undef);
  }
  else {
    return (undef, 'Must specify "language"')
  }
}

1;

