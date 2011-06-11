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
use Config::IniFiles;

use XML::Simple;
use Data::Dumper;

my $uid = 'freeswitch';
my $gid = 'daemon';
my $fs_dir = '/opt/freeswitch';
my $fs_conf_dir = '/opt/freeswitch/conf';
my $fs_fs = $fs_conf_dir.'/freeswitch.xml';
my $fs_modules = $fs_conf_dir.'/autoload_configs/modules.conf.xml';
my $fs_switch = $fs_conf_dir.'/autoload_configs/switch.conf.xml';
my $fs_event_socket = $fs_conf_dir.'/autoload_configs/event_socket.conf.xml';
my $fs_acl = $fs_conf_dir.'/autoload_configs/acl.conf.xml';
my $fs_db = $fs_conf_dir.'/autoload_configs/db.conf.xml';
my $fs_profile_dir = $fs_conf_dir.'/sip_profiles';
my $fs_example_dir = '/opt/vyatta/etc/freeswitch';
my $fs_billing = $fs_conf_dir.'/autoload_configs/nibblebill.conf.xml';
my $fs_dialplan_dir = $fs_conf_dir.'/dialplan';

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
  _loglevel     => undef,
  _max_sessions => undef,
  _mode         => undef,
  _cli          => undef,
  _cli_port     => undef,
  _cli_address  => undef,
  _cli_nat      => undef,
  _cli_acl      => undef,
  _cli_password => undef,
  _acl          => undef,
  _cdr_csv      => undef,
  _cdr_sqlite   => undef,
  _cdr_xml      => undef,
  _cdr_radius   => undef,
  _cdr_pg       => undef,
  _cdr_json     => undef,
  _profile_name => undef,
  _odbc_name    => undef,
  _odbc_dsn     => undef,
  _odbc_user    => undef,
  _odbc_pass    => undef,
  _odbc_def     => undef,
  _billing      => undef,
  _billing_odbc_name => undef,
  _billing_odbc_user => undef,
  _billing_odbc_pass => undef,
  _tls_ca       => undef,
  _tls_cert     => undef,
  _tls_key      => undef,
  _tls_dh       => undef,
  _tls_crl      => undef,
  _tls_role     => undef,
  _is_empty     => 1,
  _cdr          => [],
  _odbc         => [],
  _odbc_list    => [],
  _acls         => [],
  _acl_list     => [],
  _codecs       => [],
  _profile      => [],
  _gateway      => [],
  _user         => [],
  _language     => [],
  _modules      => [],
  _context      => [],
  _extension    => [],
  _zrtp_secure_media      => undef,
  _default_language       => undef,
  _multiple_registrations => undef,
  _sessions_per_second    => undef,
);
my @application = ('bridge', 'hangup', 'nibblebill');
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

my @modules_unsuport = ('voicemail', 'curl', 'conference', 'perl', 'python', 'enum', 'rpc', 'event-multicast', 'dingaling', 'portaudio', 'skinny', 'directory', 'distributor', 'lcr', 'spy', 'snom', 'dialplan-directory', 'dialplan-asterisk', 'shout', 'spidermonkey', 'flite', 'tts-commandline', 'rss', 'fifo');
my @modules_cdr = ('xml', 'csv', 'sqlite', 'postgresql', 'json', 'radius');
my %modules_cdr_hash = (
    'xml' => 'xml_cdr',
    'json' => 'json_cdr',
    'radius' => 'radius_cdr',
    'csv' => 'cdr_csv',
    'sqlite' => 'cdr_sqlite',
    'postgresql' => 'cdr_pg_csv',
);
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
  $self->{_cli_acl} = $config->returnValue('cli acl');
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
  my @tmp_context = $config->listNodes('dialplan context');
  $self->{_context} = \@tmp_context;
  $self->{_multiple_registrations} = $config->returnValue('multiple-registrations');
  my @tmp_profile = $config->returnValues('profile');
  $self->{_profile} = \@tmp_profile;
  $self->{_sessions_per_second} = $config->returnValue('sessions-per-second');
  $self->{_zrtp_secure_media} = $config->returnValue('zrtp-secure-media');
  my @tmp_user = $config->returnValues('_user');
  $self->{_user} = \@tmp_user;
  my @tmp_profiles = $config->listNodes("profile");
  $self->{_profile} = \@tmp_profiles;
  my @tmp_cdr = $config->listNodes('cdr');
  $self->{_cdr} = \@tmp_cdr;
  my @tmp_acls = $config->listNodes('acl');
  $self->{_acls} = \@tmp_acls;
  my @tmp_odbc = $config->listNodes('odbc');
  if (scalar(@tmp_odbc) > 0) {
    my @tmp_odbc_node = ();
    for my $sec (@tmp_odbc) {
        my $odbc_mode = (defined($config->returnValue("odbc $sec mode"))) ? $config->returnValue("odbc $sec mode") : undef;
        push(@tmp_odbc_node, $sec) if (defined($odbc_mode));
    }
    $self->{_odbc} = \@tmp_odbc_node;
  }
  $self->{_odbc_def} = (defined($config->returnValue("db default"))) ? $config->returnValue("db default") : undef;
  if (defined($self->{_odbc_def})) {
    $self->{_odbc_user} = (defined($config->returnValue("odbc $self->{_odbc_def} user"))) ? $config->returnValue("odbc $self->{_odbc_def} user") : undef;
    $self->{_odbc_pass} = (defined($config->returnValue("odbc $self->{_odbc_def} password"))) ? $config->returnValue("odbc $self->{_odbc_def} password") : undef;
    $self->{_odbc_name} = $self->{_odbc_def};
    $self->{_odbc_dsn} = $self->{_odbc_name}.':'.$self->{_odbc_user}.':'.$self->{_odbc_pass};
  }
  # Configuration NibleBilling
  if(defined($config->exists('billing'))) {
      $self->{_billing_odbc_name} = $config->returnValue('billing odbc');
      if(defined($self->{_billing_odbc_name})) {
        $self->{_billing_odbc_user} = (defined($config->returnValue("odbc $self->{_billing_odbc_name} user"))) ? $config->returnValue("odbc $self->{_billing_odbc_name} user") : undef;
        $self->{_billing_odbc_pass} = (defined($config->returnValue("odbc $self->{_billing_odbc_name} password"))) ? $config->returnValue("odbc $self->{_billing_odbc_name} password") : undef;
      }
      elsif(defined($self->{_odbc_def})) {
         $self->{_billing_odbc_name} = $self->{_odbc_name};
         $self->{_billing_odbc_user} = $self->{_odbc_user};
         $self->{_billing_odbc_pass} = $self->{_odbc_pass};
      }
      $self->{_billing} = 1;
  }
  if (scalar(@{$self->{_acls}}) > 0) {
    $self->{_acl} = 1;
    my @tmp_acl_node = ();
    for my $c (@tmp_acls) {
        my $d = $config->returnValue("acl $c default");
        my @tmp_acl_adress = $config->listNodes("acl $c address");
        my @ac = ();
        for my $ad (@tmp_acl_adress) {
          my $aa =$config->returnValue("acl $c address $ad action");
          push @ac, { cidr=>$ad, type => $aa };  
        }
        push @tmp_acl_node, { name => $c, 'default'=> $d, node => \@ac };
    }
    $self->{_acl_list} = \@tmp_acl_node;
  }
 
  return 0;
}

sub get_command {
  my ($self) = @_;
  my $cmd = "/etc/init.d/freeswitch restart"; 

  return (undef, 'Must specify "mode"') if (!defined($self->{_mode}));
  return (undef, 'Must specify "language"') if (scalar(@{$self->{_language}}) == 0);
  return (undef, 'Must specify "default-language"') if (!defined($self->{_default_language}));
  return (undef, 'Must specify "codecs"') if (scalar(@{$self->{_codecs}}) == 0);
  return (undef, 'Must specify "domain-name"') if (!defined($self->{_domain_name}));
  #return (undef, 'Must specify "dialplan context"') if (scalar(@{$self->{_context}}) == 0);
  #return (undef, 'Must specify "profile"') if (scalar(@{$self->{_profile}}) == 0);
  if (defined($self->{_cli})) {
    return (undef, 'Must specify "set service sip cli password"') if (!defined($self->{_cli_password}));
    return (undef, 'Must specify "set service sip cli listen-port"') if (!defined($self->{_cli_port}));
    return (undef, 'Must specify "set service sip cli listen-address"') if (!defined($self->{_cli_address}));
  }
  if(defined($self->{_billing})) {
    return (undef, 'Must specify "set service sip billing odbc" or "set service sip db default"') if(!defined($self->{_billing_odbc_name}));
    return (undef, 'Must specify "set service sip odbc user"') if(!defined($self->{_billing_odbc_user}));
    return (undef, 'Must specify "set service sip odbc password"') if(!defined($self->{_billing_odbc_pass}));
  }
  if (scalar(@{$self->{_cdr}}) > 0) {
    for my $rem (@{$self->{_cdr}}) {
        my $mod_file = $fs_dir."/mod/mod_".$modules_cdr_hash{$rem}.".so";
      if (!-e $mod_file) {
          return (undef, "Module is not installed: $mod_file");
      }
    }
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
    if (scalar(@{$self->{_cdr}}) > 0) {
        for my $rem (@{$self->{_cdr}}) {
            #print $fs_dir."/mod/mod_".$modules_cdr_hash{$rem}.".so\n";
            if (-e $fs_dir."/mod/mod_".$modules_cdr_hash{$rem}.".so") {
                push @{ $fs_config->{modules}->{load} }, { 'module' => "mod_".$modules_cdr_hash{$rem} };
            }
        }
    }
    if (scalar(@{$self->{_modules}}) > 0) {
        for my $rem (@{$self->{_modules}}) {
            if($rem ne 'billing') {
                push @{ $fs_config->{modules}->{load} }, { 'module' => $modules_cmd_hash{$rem} };
            }
        }
    }
    if(defined($self->{_billing_odbc_name})) {
        push @{ $fs_config->{modules}->{load} }, { 'module' => $modules_cmd_hash{billing} };
    }
    push @{ $fs_config->{modules}->{load} }, { 'module' => 'mod_lua' };
    
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_modules or die "open($fs_modules): $!";
    $fs_config_new->XMLout($fs_config, OutputFile => $fh);
    print "exec confModules\n";
}
sub ListsCodecs {
    my ($codec_list) = @_;
    my $is_start = undef;
    foreach my $key (@{$codec_list}) {
        if (defined($is_start)) {
            $is_start .= ','.$global_codecs_hash{$key};
        }
        else {
            $is_start = $global_codecs_hash{$key};
        }
    }
    return $is_start;
}
sub confGateway {
    my ($self, $name, $profile, $action, $action_name, $action_val) = @_;
    my $cmd = undef;
    my $fs_gateway_dir = "$fs_profile_dir/$profile";
    my $fs_gateway = "$fs_profile_dir/$profile/$name.xml";
    #print "exec confGateway\n";

    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");
    #print "Action: $action - $action_val\n";
    if ($action eq 'delete' && $action_val eq 'gateway') {
        if (-e $fs_gateway) {
            unlink($fs_gateway);
            $cmd = "Delete Gateway: $name (successfully).\n";
        }
        else {
            $cmd = "File was not deleted.\n"
        }
        return ($cmd, undef);
    }
    else {
        if (!-e "$fs_gateway_dir/") {
            mkdir($fs_gateway_dir, 0750);
            system("chown $uid:$gid $fs_gateway_dir");
            #print "Not exists profile dir: $fs_gateway_dir/\n";
        }
        my $user = undef;
        my $register = undef;
        my $password = undef;
        my $mode = (defined($config->returnValue("profile $profile gateway $name mode"))) ? $config->returnValue("profile $profile gateway $name mode") : undef;
        return (undef, "Must specify \"profile $profile gateway $name mode\"") if (!defined($mode) && ($action_name eq 'update' || $action_name eq 'create'));
        my $from_domain = (defined($config->returnValue("profile $profile gateway $name from-domain"))) ? $config->returnValue("profile $profile gateway $name from-domain") : undef;
        if ($mode eq 'trunk') {
            $user = 'pass';
            $register = 'false';
            $password = 'pass';
        }
        else {
            $user = (defined($config->returnValue("profile $profile gateway $name user"))) ? $config->returnValue("profile $profile gateway $name user") : undef;
            $register = (defined($config->returnValue("profile $profile gateway $name register"))) ? $config->returnValue("profile $profile gateway $name register") : 'true';
            $password = (defined($config->returnValue("profile $profile gateway $name password"))) ? $config->returnValue("profile $profile gateway $name password") : undef;
        }

        my $retry = (defined($config->returnValue("profile $profile gateway $name retry-seconds"))) ? $config->returnValue("profile $profile gateway $name retry-seconds") : 30;
        my $register_transport = (defined($config->returnValue("profile $profile gateway $name register-transport"))) ? $config->returnValue("profile $profile gateway $name register-transport") : 'udp';
        my $register_proxy = (defined($config->returnValue("profile $profile gateway $name register-proxy"))) ? $config->returnValue("profile $profile gateway $name register-proxy") : undef;
        my $realm = (defined($config->returnValue("profile $profile gateway $name realm"))) ? $config->returnValue("profile $profile gateway $name realm") : undef;
        my $proxy = (defined($config->returnValue("profile $profile gateway $name proxy"))) ? $config->returnValue("profile $profile gateway $name proxy") : undef;
        my $ping = (defined($config->returnValue("profile $profile gateway $name ping"))) ? $config->returnValue("profile $profile gateway $name ping") : undef;
        my $from_user = (defined($config->returnValue("profile $profile gateway $name from-user"))) ? $config->returnValue("profile $profile gateway $name from-user") : undef;
        my $extension = (defined($config->returnValue("profile $profile gateway $name extension"))) ? $config->returnValue("profile $profile gateway $name extension") : undef;
        my $expire = (defined($config->returnValue("profile $profile gateway $name expire-seconds"))) ? $config->returnValue("profile $profile gateway $name expire-seconds") : undef;
        my $contact_params = (defined($config->returnValue("profile $profile gateway $name contact-params"))) ? $config->returnValue("profile $profile gateway $name contact-params") : undef;
        my $callerid = (defined($config->returnValue("profile $profile gateway $name caller-id-in-from"))) ? $config->returnValue("profile $profile gateway $name caller-id-in-from") : 'true';
        my $cid = (defined($config->returnValue("profile $profile gateway $name cid-type"))) ? 'rpid' : undef;
        my $extension_in_contact = (defined($config->returnValue("profile $profile gateway $name extension-in-contact"))) ? $config->returnValue("profile $profile gateway $name extension-in-contact") : undef;
        
        if (!defined($user) && $action eq 'delete') {
            return (undef, undef); 
        }
        elsif (!defined($user)) {
            return (undef, "Must specify \"profile $name gateway $name user\""); 
        }
        if (!defined($realm) && $action eq 'delete') {
            return (undef, undef); 
        }
        elsif (!defined($realm)) {
            return (undef, "Must specify \"profile $name gateway $name realm\"");
        }
        if (!defined($password) && $action eq 'delete') {
            return (undef, undef); 
        }
        elsif (!defined($password)) {
            return (undef, "Must specify \"profile $name gateway $name password\"");
        }
        if (!defined($from_domain) && $action eq 'delete') {
            return (undef, undef); 
        }
        elsif (!defined($from_domain)) {
            return (undef, "Must specify \"profile $name gateway $name from-domain\""); 
        }

        my $fs_config_new = XML::Simple->new(rootname=>'include');
        my @a = ();
        my $fs_config = XMLin("<include><gateway name=\"$name\"/></include>", KeyAttr => {});
        push @a, {name => 'username', value => $user };
        push @a, {name => 'password', value => $password };
        push @a, {name => 'realm', value => $realm };
        push @a, {name => 'from-domain', value => $from_domain };
        push @a, {name => 'from-user', value => $from_user } if (defined($from_user));
        push @a, {name => 'register', value => $register };
        push @a, {name => 'register-transport', value => $register_transport };
        push @a, {name => 'register-proxy', value => $register_proxy } if (defined($register_proxy));
        push @a, {name => 'proxy', value => $proxy } if (defined($proxy));
        push @a, {name => 'retry-seconds', value => $retry };
        push @a, {name => 'ping', value => $ping } if (defined($ping));
        push @a, {name => 'expire-seconds', value => $expire } if (defined($expire));
        push @a, {name => 'caller-id-in-from', value => $callerid };
        push @a, {name => 'extension', value => $extension } if (defined($extension));
        push @a, {name => 'contact-params', value => $contact_params } if (defined($contact_params));
        push @a, {name => 'cid-type', value => $cid } if (defined($cid));
        push @a, {name => 'extension-in-contact', value => $extension_in_contact } if (defined($extension_in_contact));
        
        #my $ = (defined($config->returnValue("profile $profile gateway $name "))) ? $config->returnValue("profile $profile gateway $name ") : '';
        #return (undef, "Must specify \"profile $name gateway $name \"") if (!defined($));
        #push @a, {name => '', value => $ } if (defined($));
        $fs_config->{gateway}->{param} = \@a;
        my @tmp_variables = $config->listNodes("profile $profile gateway $name variables");
        if (scalar(@tmp_variables) > 0) {
            my @tmp_variables_node = ();
            for my $c (@tmp_variables) {
                my $d =(defined($config->returnValue("profile $profile gateway $name variables $c data"))) ? $config->returnValue("profile $profile gateway $name variables $c data") : undef;
                my $ad =(defined($config->returnValue("profile $profile gateway $name variables $c direction"))) ? $config->returnValue("profile $profile gateway $name variables $c direction") : undef;
                return (undef, "Must specify \"profile $profile gateway $name variables $c data\"") if (!defined($d));
                if (defined($ad)) {
                    push @tmp_variables_node, { name => $c, data => $d, direction => $ad };
                }
                else {
                    push @tmp_variables_node, { name => $c, data => $d };
                }
            }
            $fs_config->{gateway}->{variables}->{variable} = \@tmp_variables_node;
        }
        open my $fh, '>:encoding(UTF-8)', $fs_gateway or die "open($fs_gateway): $!";
        $fs_config_new->XMLout($fs_config, OutputFile => $fh);
        #$cmd = $fs_config_new->XMLout($fs_config);
        $cmd = "Create Gateway: $fs_gateway";
        system("chown $uid:$gid $fs_gateway");
        system("chmod 640 $fs_gateway");
        #$cmd = undef;
        return ($cmd, undef);
    }
}
sub confExtension {
    my ($self, $name, $context, $action) = @_;
    my $address = undef;
    my $cmd = undef;
    my $fs_extension = undef;
    my $fs_extension_example = undef;
    my $fs_extension_file = undef;
    my $fs_extension_dir = $fs_dialplan_dir.'/'.$context;

    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");
    my $mode = (defined($config->returnValue("dialplan context $context extension $name mode"))) ? $config->returnValue("dialplan context $context extension $name mode") : undef;
    my $rule = (defined($config->returnValue("dialplan context $context extension $name rule"))) ? $config->returnValue("dialplan context $context extension $name rule") : undef;
    if (defined($mode)) {
        $fs_extension_example = $fs_example_dir."/extension_$mode.xml";
    }
    else {
        $fs_extension_example = $fs_example_dir."/extension.xml";
    }
    if (defined($rule)) {
        $fs_extension_file = $fs_extension_dir.'/'.$rule.'-'.$name.'.xml';
    }
    else {
        $fs_extension_file = $fs_extension_dir.'/'.$name.'.xml';
    }
    #my $ = (defined($config->returnValue("dialplan context $context extension $name "))) ? $config->returnValue("dialplan context $context extension $name ") : undef;

    if ($action eq 'delete') {
        if (-e $fs_extension_file) {
            unlink($fs_extension_file);
            $cmd = "Delete dialplan extension: $name (successfully).\n";
        }
        else {
            $cmd = "File was not deleted.\n"
        }
        return ($cmd, undef);
    }
    else {

        if (!-e $fs_extension_file && -e $fs_extension_example) {
            $fs_extension = $fs_extension_example;
        }
        elsif (-e $fs_extension_file) {
            $fs_extension = $fs_extension_file;
        }
        else {
            return (undef, "Not exists example dialplan context: $fs_extension_example and $fs_extension_file\n");
        }
        if (!-e "$fs_extension_dir/") {
            mkdir($fs_extension_dir, 0750);
            system("chown $uid:$gid $fs_extension_dir");
            #print "Not exists profile dir: $fs_gateway_dir/\n";
        }
        my $fs_config = XMLin($fs_extension, KeyAttr=>{});
        #delete $fs_config->{context}->{'X-PRE-PROCESS'};
        $fs_config->{extension}->{name} = $name;
        if (defined($mode) && $mode eq 'local') {
            my $i = 0;
            if ($fs_config->{extension}->{condition}->{field} eq 'destination_number') { $fs_config->{extension}->{condition}->{expression} = 'ssssssssssssssssssssssssss'; }
            foreach my $fs (@{$fs_config->{extension}->{condition}->{action}}) {
                if ($fs->{application} eq 'set') { $fs->{data} = 'ssssssssssssssssssssssssss'; }
                #elsif ($fs->{} eq 'rtp-ip') { $fs->{value} = $rtp_ip; }
                $i++;
            }
        }
        #my @e = ();
        #if (scalar(@{$self->{_extension}}) > 0) {
        #    push @e, { cmd => "include", data => "$name/*.xml" };
        #    $fs_config->{context}->{'X-PRE-PROCESS'} = \@e;
        #}
        my $fs_config_new = XML::Simple->new(rootname=>'include');
        open my $fh, '>:encoding(UTF-8)', $fs_extension_file or die "open($fs_extension_file): $!";
        $fs_config_new->XMLout($fs_config, OutputFile => $fh);
        $cmd = $fs_config_new->XMLout($fs_config);
        #$cmd = "Create Dialplan extension: $fs_extension_file";
        system("chown $uid:$gid $fs_extension_file");
        system("chmod 640 $fs_extension_file");
        return ($cmd, undef);
    }
}
sub confContext {
    my ($self, $name, $action) = @_;
    my $address = undef;
    my $cmd = undef;
    my $fs_context = undef;
    my $fs_context_file = $fs_dialplan_dir.'/'.$name.'.xml';

    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");
    if ($action eq 'delete') {
        if (-e $fs_context_file) {
            unlink($fs_context_file);
            system("rm -Rf $fs_dialplan_dir/$name");
            $cmd = "Delete dialplan context: $name (successfully).\n";
        }
        else {
            $cmd = "File was not deleted.\n"
        }
        return ($cmd, undef);
    }
    else {
        my $mode = $config->returnValue("dialplan context $name mode");
        my $fs_context_example = $fs_example_dir."/context_$mode.xml";

        if (!-e $fs_context_file && -e $fs_context_example) {
            $fs_context = $fs_context_example;
        }
        elsif (-e $fs_context_file) {
            $fs_context = $fs_context_file;
        }
        else {
            return (undef, "Not exists example dialplan context: $fs_context_example and $fs_context_file\n");
        }
        my $fs_config = XMLin($fs_context, KeyAttr=>{});
        delete $fs_config->{context}->{'X-PRE-PROCESS'};
        $fs_config->{context}->{name} = $name;
        
        #my @e = ();
        #if (scalar(@{$self->{_extension}}) > 0) {
        #    push @e, { cmd => "include", data => "$name/*.xml" };
        #    $fs_config->{context}->{'X-PRE-PROCESS'} = \@e;
        #}
        my $fs_config_new = XML::Simple->new(rootname=>'include');
        open my $fh, '>:encoding(UTF-8)', $fs_context_file or die "open($fs_context_file): $!";
        $fs_config_new->XMLout($fs_config, OutputFile => $fh);
        #$cmd = $fs_config_new->XMLout($fs_config);
        $cmd = "Create Dialplan context: $fs_context_file";
        system("chown $uid:$gid $fs_context_file");
        system("chmod 640 $fs_context_file");
        return ($cmd, undef);
    }
}
sub confProfile {
    my ($self, $name, $action) = @_;
    #print "exec confProfile\n";
    my $address = undef;
    my $cmd = undef;
    my $fs_profile = undef;

    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");
    $self->{_profile_name} = $name;
    
    my @tmp_gateways = $config->listNodes("profile $name gateway");
    $self->{_gateway} = \@tmp_gateways;

    my $fs_profile_file = $fs_profile_dir."/$name.xml";
    if ($action eq 'delete') {
        if (-e $fs_profile_file) {
            unlink($fs_profile_file);
            system("rm -Rf $fs_profile_dir/$name");
            $cmd = "Delete profile: $name (successfully).\n";
        }
        else {
            $cmd = "File was not deleted.\n"
        }
        return ($cmd, undef);
    }
    else {
        return (undef, 'Must specify "dialplan context"') if (scalar(@{$self->{_context}}) == 0);
        my $mode = $config->returnValue("profile $name mode");
        $address = $config->returnValue("profile $name address");
        my $inbound_codec_prefs = undef;
        my $outbound_codec_prefs = undef;
        return (undef, "Must specify \"profile $name address\"") if (!defined($address));
        my @tmp_codec_inbound = $config->returnValues("profile $name codec inbound");
        if (scalar(@tmp_codec_inbound) > 0) {
            $inbound_codec_prefs = ListsCodecs(\@tmp_codec_inbound);
            my @tmp_codec_outbound = $config->returnValues("profile $name codec outbound");
            if (scalar(@tmp_codec_outbound) > 0) {
                $outbound_codec_prefs = ListsCodecs(\@tmp_codec_outbound);
            }
            else {
                $outbound_codec_prefs = $inbound_codec_prefs;
            }
        }
        else {
            return (undef, "Must specify \"profile $name codec inbound\"");
        }

        my $rtp_ip = $address;
        my $ext_sip_ip = $address;
        my $ext_rtp_ip = $address;

        #my $log_auth_failures_def = undef;
        #my $challenge_realm_def = undef;
        my $accept_blind_auth_def = undef;
        my $disable_transcoding_def = undef;
        my $bitpacking_def = undef;
        my $inbound_late_negotiation_def = undef; 

        #my $rtp_ip = $config->returnValue("profile $name rtp-ip");
        #my $ext_rtp_ip = $config->returnValue("profile $name ext-rtp-ip");
        #my $ext_sip_ip = $config->returnValue("profile $name ext-sip-ip");
        my $context = 'default';
        my $disable_transcoding = 'false';
        if (defined($config->returnValue("profile $name context"))) {
            $context = $config->returnValue("profile $name context");
        }
        if (defined($config->returnValue("profile $name codec transcoding")) && $config->returnValue("profile $name codec transcoding") eq 'disable') {
            $disable_transcoding = 'true';
        }
        my $challenge_realm = (defined($config->returnValue("profile $name auth challenge-realm"))) ? $config->returnValue("profile $name auth challenge-realm") : 'auto_from';
        my $log_auth_failures = (defined($config->returnValue("profile $name auth log-auth-failures"))) ? $config->returnValue("profile $name auth log-auth-failures") : 'true';
        my $accept_blind_auth = (defined($config->returnValue("profile $name auth accept-blind-auth"))) ? $config->returnValue("profile $name auth accept-blind-auth") : undef;
        my $bitpacking = (defined($config->returnValue("profile $name codec bitpacking")) && $config->returnValue("profile $name codec bitpacking") eq 'enable') ? 'aal2' : undef;
        my $inbound_codec_negotiation = (defined($config->returnValue("profile $name codec negotiation"))) ? $config->returnValue("profile $name codec negotiation") : 'generous';
        my $inbound_late_negotiation = (defined($config->returnValue("profile $name codec late-negotiation"))) ? $config->returnValue("profile $name codec late-negotiation") : undef;
        my $local_network_acl = (defined($config->returnValue("profile $name acl local-network"))) ? $config->returnValue("profile $name acl local-network") : undef;
        my $local_network_acl_def = undef;
        my $apply_inbound_acl = (defined($config->returnValue("profile $name acl inbound"))) ? $config->returnValue("profile $name acl inbound") : undef;
        my $apply_inbound_acl_def = undef;
        my $apply_register_acl = (defined($config->returnValue("profile $name acl register"))) ? $config->returnValue("profile $name acl register") : undef;
        my $apply_register_acl_def = undef;
        my $apply_proxy_acl = (defined($config->returnValue("profile $name acl proxy"))) ? $config->returnValue("profile $name acl proxy") : undef;
        my $apply_proxy_acl_def = undef;
        my $auth_all_packets_d = 'false';
        my $auth_calls_d = 'true';
        if ($mode eq 'external') {
            $auth_all_packets_d = 'false';
            $auth_calls_d = 'false';
        }
        my $auth_all_packets = (defined($config->returnValue("profile $name auth all-packets"))) ? $config->returnValue("profile $name auth all-packets") : $auth_all_packets_d;
        my $auth_calls = (defined($config->returnValue("profile $name auth calls"))) ? $config->returnValue("profile $name auth calls") : $auth_calls_d;
 
        my $fs_profile_example = $fs_example_dir."/$mode.xml";

        if (-e $fs_profile_file) {
            #print "Exists profile: $fs_profile_file\n";
            $fs_profile = $fs_profile_file;
        }
        elsif (-e $fs_profile_example) {
            #print "Exists example profile: $fs_profile_example\n";
            $fs_profile = $fs_profile_example;
        }
        else {
            return (undef, "Not exists example profile: $fs_profile_example and profile $fs_profile\n");
        }
        #my $ = (defined($config->returnValue("profile $name "))) ? $config->returnValue("profile $name ") : '';
        #return (undef, "Must specify \"profile $name gateway $name \"") if (!defined($));
        #push @a, {name => '', value => $ } if (defined($));
        my $fs_config = XMLin($fs_profile, KeyAttr=>{});
        delete $fs_config->{aliases};
        delete $fs_config->{gateways};
        delete $fs_config->{domains};
        my @d = ();
        push @d, {name => 'all', alias => 'false', parse => 'true' };
        $fs_config->{domains}->{domain} = \@d;
        my @g = ();
        if (scalar(@{$self->{_gateway}}) > 0) {
            push @g, { cmd => "include", data => "$name/*.xml" };
            $fs_config->{gateways}->{'X-PRE-PROCESS'} = \@g;
        }
        my $i = 0;
        foreach my $fs (@{$fs_config->{settings}->{param}}) {
            if ($fs->{name} eq 'sip-ip') { $fs->{value} = $address; }
            elsif ($fs->{name} eq 'rtp-ip') { $fs->{value} = $rtp_ip; }
            elsif ($fs->{name} eq 'ext-rtp-ip') { $fs->{value} = $ext_rtp_ip; }
            elsif ($fs->{name} eq 'ext-sip-ip') { $fs->{value} = $ext_sip_ip; }
            elsif ($fs->{name} eq 'sip-port') { $fs->{value} = $config->returnValue("profile $name port"); }
            elsif ($fs->{name} eq 'context') { $fs->{value} = $context; }
            elsif ($fs->{name} eq 'log-auth-failures') { $fs->{value} = $log_auth_failures; }
            elsif ($fs->{name} eq 'challenge-realm') { $fs->{value} = $challenge_realm; }
            elsif ($fs->{name} eq 'inbound-codec-prefs') { $fs->{value} = $inbound_codec_prefs; }
            elsif ($fs->{name} eq 'outbound-codec-prefs') { $fs->{value} = $outbound_codec_prefs; }
            elsif ($fs->{name} eq 'inbound-codec-negotiation') { $fs->{value} = $inbound_codec_negotiation; }
            elsif ($fs->{name} eq 'accept-blind-auth') {
                $fs->{value} = $accept_blind_auth; 
                $accept_blind_auth_def = $i;
            }
            elsif ($fs->{name} eq 'auth-all-packets') { $fs->{value} = $auth_all_packets; }
            elsif ($fs->{name} eq 'auth-calls') { $fs->{value} = $auth_calls; }
            elsif ($fs->{name} eq 'disable-transcoding') { 
                $fs->{value} = $disable_transcoding; 
                $disable_transcoding_def = $i;
            }
            elsif ($fs->{name} eq 'bitpacking') { 
                $fs->{value} = $bitpacking;
                $bitpacking_def = $i;
            }
            elsif ($fs->{name} eq 'inbound-late-negotiation') {
                $fs->{value} = $inbound_late_negotiation;
                $inbound_late_negotiation_def = $i;
            }
            elsif ($fs->{name} eq 'local-network-acl') {
                $fs->{value} = $local_network_acl;
                $local_network_acl_def = $i;
            }
            elsif ($fs->{name} eq 'apply-inbound-acl') {
                $fs->{value} = $apply_inbound_acl;
                $apply_inbound_acl_def = $i;
            }
            elsif ($fs->{name} eq 'apply-register-acl') {
                $fs->{value} = $apply_register_acl;
                $apply_register_acl_def = $i;
            }
            elsif ($fs->{name} eq 'apply-proxy-acl') {
                $fs->{value} = $apply_proxy_acl;
                $apply_proxy_acl_def = $i;
            }
            #elsif ($fs->{name} eq '') { $fs->{value} = $; }
            $i++;
        }
        push @{ $fs_config->{settings}->{param} }, {name => 'apply-inbound-acl', value => $apply_inbound_acl } if (defined($apply_inbound_acl) && !defined($apply_inbound_acl_def));
        splice(@{$fs_config->{settings}->{param}}, $apply_inbound_acl_def, 1) if (!defined($apply_inbound_acl) && defined($apply_inbound_acl_def));
        push @{ $fs_config->{settings}->{param} }, {name => 'apply-register-acl', value => $apply_register_acl } if (defined($apply_register_acl) && !defined($apply_register_acl_def));
        splice(@{$fs_config->{settings}->{param}}, $apply_register_acl_def, 1) if (!defined($apply_register_acl) && defined($apply_register_acl_def));
        push @{ $fs_config->{settings}->{param} }, {name => 'apply-proxy-acl', value => $apply_proxy_acl } if (defined($apply_proxy_acl) && !defined($apply_proxy_acl_def));
        splice(@{$fs_config->{settings}->{param}}, $apply_proxy_acl_def, 1) if (!defined($apply_proxy_acl) && defined($apply_proxy_acl_def));
        push @{ $fs_config->{settings}->{param} }, {name => 'local-network-acl', value => $local_network_acl } if (defined($local_network_acl) && !defined($local_network_acl_def));
        splice(@{$fs_config->{settings}->{param}}, $local_network_acl_def, 1) if (!defined($local_network_acl) && defined($local_network_acl_def));
        push @{ $fs_config->{settings}->{param} }, { name => 'accept-blind-auth', value => $accept_blind_auth } if (defined($accept_blind_auth) && !defined($accept_blind_auth_def));
        splice(@{$fs_config->{settings}->{param}}, $accept_blind_auth_def, 1) if (!defined($accept_blind_auth) && defined($accept_blind_auth_def));
        push @{ $fs_config->{settings}->{param} }, { name => 'disable-transcoding', value => $disable_transcoding } if (!defined($disable_transcoding_def));
        #splice(@{$fs_config->{settings}->{param}}, $, 1) if (!defined($) && defined($));
        push @{ $fs_config->{settings}->{param} }, { name => 'bitpacking', value => $bitpacking } if (defined($bitpacking) && !defined($bitpacking_def));
        splice(@{$fs_config->{settings}->{param}}, $bitpacking_def, 1) if (!defined($bitpacking) && defined($bitpacking_def));
        push @{ $fs_config->{settings}->{param} }, { name => 'inbound-late-negotiation', value => $inbound_late_negotiation } if (defined($inbound_late_negotiation) && !defined($inbound_late_negotiation_def));
        splice(@{$fs_config->{settings}->{param}}, $inbound_late_negotiation_def, 1) if (!defined($inbound_late_negotiation) && defined($inbound_late_negotiation_def));
        #push @{ $fs_config->{settings}->{param} }, { name => '', value => $ } if (defined($) && !defined($));
        #splice(@{$fs_config->{settings}->{param}}, $, 1) if (!defined($) && defined($));
        my $fs_config_new = XML::Simple->new(rootname=>'profile');
        $fs_config->{name} = $name;
        open my $fh, '>:encoding(UTF-8)', $fs_profile_file or die "open($fs_profile_file): $!";
        $fs_config_new->XMLout($fs_config, OutputFile => $fh);
        #$cmd = $fs_config_new->XMLout($fs_config);
        $cmd = "Create Profile: $fs_profile_file";
        #$cmd = undef;
        system("chown $uid:$gid $fs_profile_file");
        system("chmod 640 $fs_profile_file");
        return ($cmd, undef);
    }
    
}
sub confCdr {
    my ($self, $name, $action) = @_;
    my $fs_cdr = $fs_conf_dir.'/autoload_configs/'.$modules_cdr_hash{$name}.'.conf.xml';
    my $cmd = undef;
    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");
    if ($action eq 'delete') {
        return ("Delete cdr module $name\n", undef);
    }
    elsif ($name eq 'csv') {
        return ("To edit the settings: $fs_cdr\n", undef);
    }
    elsif ($name eq 'xml') {
        my $url = (defined($config->returnValue("cdr xml url"))) ? $config->returnValue("cdr xml url") : undef;
        my $username = (defined($config->returnValue("cdr xml username"))) ? $config->returnValue("cdr xml username") : undef;
        my $password = (defined($config->returnValue("cdr xml password"))) ? $config->returnValue("cdr xml password") : '';
        my $retries = (defined($config->returnValue("cdr xml retries"))) ? $config->returnValue("cdr xml retries") : undef;
        my $delay = (defined($config->returnValue("cdr xml delay"))) ? $config->returnValue("cdr xml delay") : undef;
        my $log_http_and_disk = (defined($config->returnValue("cdr xml log-http-and-disk"))) ? $config->returnValue("cdr xml log-http-and-disk") : undef;
        my $log_dir = (defined($config->returnValue("cdr xml log-dir"))) ? $config->returnValue("cdr xml log-dir") : undef;
        my $log_b_leg = (defined($config->returnValue("cdr xml log-b-leg"))) ? $config->returnValue("cdr xml log-b-leg") : 'false';
        my $prefix_a_leg = (defined($config->returnValue("cdr xml prefix-a-leg"))) ? $config->returnValue("cdr xml prefix-a-leg") : 'true';
        my $encode = (defined($config->returnValue("cdr xml encode"))) ? $config->returnValue("cdr xml encode") : 'true';
        my $disable_100_continue = (defined($config->returnValue("cdr xml disable-100-continue"))) ? $config->returnValue("cdr xml disable-100-continue") : undef;
        my $err_log_dir = (defined($config->returnValue("cdr xml err-log-dir"))) ? $config->returnValue("cdr xml err-log-dir") : undef;
        my $auth_scheme = (defined($config->returnValue("cdr xml auth-scheme"))) ? $config->returnValue("cdr xml auth-scheme") : undef;
        
        my $enable_cacert_check = (defined($config->returnValue("cdr xml cacert-check"))) ? $config->returnValue("cdr xml cacert-check") : undef;
        my $enable_ssl_verifyhost = (defined($config->returnValue("cdr xml verifyhost"))) ? $config->returnValue("cdr xml verifyhost") : undef;
        my $ssl_cert_path = (defined($config->returnValue("cdr xml cert-path"))) ? $config->returnValue("cdr xml cert-path") : undef;
        my $ssl_key_path = (defined($config->returnValue("cdr xml key-path"))) ? $config->returnValue("cdr xml key-path") : undef;
        my $ssl_key_password = (defined($config->returnValue("cdr xml key-password"))) ? $config->returnValue("cdr xml key-password") : undef;
        my $ssl_cacert_file = (defined($config->returnValue("cdr xml cacert-file"))) ? $config->returnValue("cdr xml cacert-file") : undef;
        my $ssl_version = (defined($config->returnValue("cdr xml version"))) ? $config->returnValue("cdr xml version") : undef;
        
        my $fs_config = XMLin('<configuration name="xml_cdr.conf" description="XML CDR CURL logger"><settings /></configuration>', KeyAttr=>{});
        my @a = ();
        push @a, { name => 'url', value => $url } if (defined($url));
        push @a, { name => 'cred', value => "$username:$password" } if (defined($username) && defined($password));
        push @a, { name => 'auth-scheme', value => $auth_scheme } if (defined($auth_scheme));
        push @a, { name => 'encode', value => $encode } if (defined($encode));
        push @a, { name => 'retries', value => $retries } if (defined($retries));
        push @a, { name => 'delay', value => $delay } if (defined($delay));
        push @a, { name => 'log-http-and-disk', value => $log_http_and_disk } if (defined($log_http_and_disk));
        if (defined($log_dir)) {
            if (!-e $log_dir) {
                system("mkdir -p $log_dir");
                system("chmod 0750 $log_dir");
                system("chown $uid:$gid $log_dir");
            }
            push @a, { name => 'log-dir', value => $log_dir };
        }
        if (defined($err_log_dir)) {
            if (!-e $err_log_dir) {
                system("mkdir -p $err_log_dir");
                system("chmod 0750 $err_log_dir");
                system("chown $uid:$gid $err_log_dir");
            }
            push @a, { name => 'err-log-dir', value => $err_log_dir };
        }
        push @a, { name => 'log-b-leg', value => $log_b_leg } if (defined($log_b_leg));
        push @a, { name => 'prefix-a-leg', value => $prefix_a_leg } if (defined($prefix_a_leg));
        push @a, { name => 'disable-100-continue', value => $disable_100_continue } if (defined($disable_100_continue));

        push @a, { name => 'enable-cacert-check', value => $enable_cacert_check } if (defined($enable_cacert_check));
        push @a, { name => 'ssl-cacert-file', value => $ssl_cacert_file } if (defined($ssl_cacert_file));
        push @a, { name => 'ssl-cert-path', value => $ssl_cert_path } if (defined($ssl_cert_path));
        push @a, { name => 'ssl-key-password', value => $ssl_key_password } if (defined($ssl_key_password));
        push @a, { name => 'ssl-key-path', value => $ssl_key_path } if (defined($ssl_key_path));
        push @a, { name => 'enable-ssl-verifyhost', value => $enable_ssl_verifyhost } if (defined($enable_ssl_verifyhost));
        push @a, { name => 'ssl-version', value => $ssl_version } if (defined($ssl_version));

        #my $ = (defined($config->returnValue("cdr xml "))) ? $config->returnValue("cdr xml ") : undef;
        #push @a, { name => '', value => $ } if (defined($));
        
        $fs_config->{settings}->{param} =\@a;
        my $fs_config_new = XML::Simple->new(rootname=>'configuration');
        open my $fh, '>:encoding(UTF-8)', $fs_cdr or die "open($fs_cdr): $!";
        $fs_config_new->XMLout($fs_config, OutputFile => $fh);
        #$cmd = $fs_config_new->XMLout($fs_config);
        $cmd = "Create cdr: $name\n";
        #$cmd = undef;
        return ($cmd, undef);
    }
    else {
        return ("no cdr module $name\n", undef);
    }
}
#sub confTemp {
    #my ($self, $name, $action) = @_;
    #my $fs_config = XMLin($fs_event_socket, KeyAttr=>{});
    #if ($name eq 'xml') {
        ##my $ = (defined($config->returnValue("profile $name "))) ? $config->returnValue("profile $name ") : undef;
        ##my $_def = undef;
        #my $i = 0;
        #foreach my $fs (@{$fs_config->{settings}->{param}}) {
            #elsif ($fs->{name} eq '') {
                #$fs->{value} = $;
                #$_def = $i;
            #}
            #$i++;
        #}
        ##push @{ $fs_config->{settings}->{param} }, { name => '', value => $ } if (defined($) && !defined($));
        ##splice(@{$fs_config->{settings}->{param}}, $, 1) if (!defined($) && defined($));
        
        #open my $fh, '>:encoding(UTF-8)', $fs_profile_file or die "open($fs_profile_file): $!";
        #$fs_config_new->XMLout($fs_config, OutputFile => $fh);
        ##$cmd = $fs_config_new->XMLout($fs_config);
        ##$cmd = "Create Gateway: $fs_gateway\n";
        #$cmd = undef;
        #return ($cmd, undef);
    #}
#}

sub confCli {
    my ($self) = @_;
    my $cmd = undef;
    my $fs_config = XMLin($fs_event_socket, KeyAttr=>{});
    my $apply_inbound_acl_cli = undef;
    my $i = 0;
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
        elsif ($fs->{name} eq 'apply-inbound-acl') {
            $fs->{value} = $self->{_cli_acl};
            $apply_inbound_acl_cli = $i;
        }
        $i++;
    }
    push @{ $fs_config->{settings}->{param} }, { name => 'apply-inbound-acl', value => $self->{_cli_acl}} if (defined($self->{_cli_acl}) && !defined($apply_inbound_acl_cli));
    splice(@{$fs_config->{settings}->{param}}, $apply_inbound_acl_cli, 1) if (!defined($self->{_cli_acl}) && defined($apply_inbound_acl_cli));
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_event_socket or die "open($fs_event_socket): $!";
    $fs_config_new->XMLout($fs_config, OutputFile => $fh);
    #$cmd = $fs_config_new->XMLout($fs_config);
    $cmd = "Create cli : $fs_event_socket\n";
    #$cmd = undef;
    return ($cmd, undef);
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
    #$cmd = "Create Gateway: $fs_gateway\n";
    #$cmd = undef;
    print "exec confSwitch\n";
}

sub confBilling {
    my ($self) = @_;
    my $cmd = undef;
    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");
    my $fs_config = XMLin('<configuration name="nibblebill.conf" description="Nibble Billing"><settings /></configuration>', KeyAttr=>{});
    my @a = ();
    
    my $db_column_account = (defined($config->returnValue("billing column-account"))) ? $config->returnValue("billing column-account") : 'id';
    push @a, { name => 'db_column_account', value => $db_column_account };
    my $db_column_cash = (defined($config->returnValue("billing column-cash"))) ? $config->returnValue("billing column-cash") : 'cash';
    push @a, { name => 'db_column_cash', value => $db_column_cash };
    my $custom_sql_lookup = (defined($config->returnValue("billing custom-sql-lookup"))) ? $config->returnValue("billing custom-sql-lookup") : undef;
    push @a, { name => 'custom_sql_lookup', value => $custom_sql_lookup } if (defined($custom_sql_lookup));
    my $custom_sql_save = (defined($config->returnValue("billing custom-sql-save"))) ? $config->returnValue("billing custom-sql-save") : undef;
    push @a, { name => 'custom_sql_save', value => $custom_sql_save } if (defined($custom_sql_save));
    my $global_heartbeat = (defined($config->returnValue("billing heartbeat"))) ? $config->returnValue("billing heartbeat") : '60';
    push @a, { name => 'global_heartbeat', value => $global_heartbeat };
    my $lowbal_action = (defined($config->returnValue("billing lowbal-action"))) ? $config->returnValue("billing lowbal-action") : 'play ding';
    push @a, { name => 'lowbal_action', value => $lowbal_action };
    my $lowbal_amt = (defined($config->returnValue("billing lowbal-amt"))) ? $config->returnValue("billing lowbal-amt") : '5';
    push @a, { name => 'lowbal_amt', value => $lowbal_amt };
    my $nobal_action = (defined($config->returnValue("billing nobal-action"))) ? $config->returnValue("billing nobal-action") : 'hangup';
    push @a, { name => 'nobal_action', value => $nobal_action };
    my $nobal_amt = (defined($config->returnValue("billing nobal-amt"))) ? $config->returnValue("billing nobal-amt") : '0';
    push @a, { name => 'nobal_amt', value => $nobal_amt };
    my $percall_action = (defined($config->returnValue("billing percall-action"))) ? $config->returnValue("billing percall-action") : 'hangup';
    push @a, { name => 'percall_action', value => $percall_action };
    my $percall_max_amt = (defined($config->returnValue("billing percall-max-amt"))) ? $config->returnValue("billing percall-max-amt") : '100';
    push @a, { name => 'percall_max_amt', value => $percall_max_amt };
    my $db_table = (defined($config->returnValue("billing table"))) ? $config->returnValue("billing table") : 'accounts';
    push @a, { name => 'db_table', value => $db_table };
    push @a, { name => 'db_username', value => $self->{_billing_odbc_user} } if (defined($self->{_billing_odbc_user}));
    push @a, { name => 'db_password', value => $self->{_billing_odbc_pass} } if (defined($self->{_billing_odbc_pass}));
    push @a, { name => 'db_dsn', value => $self->{_billing_odbc_name} } if (defined($self->{_billing_odbc_name}));
    #my $ = (defined($config->returnValue("billing "))) ? $config->returnValue("billing ") : '';
    #push @a, { name => '', value => $ } if (defined($));
    
    $fs_config->{'settings'}->{param} = \@a;
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_billing or die "open($fs_billing): $!";
    $fs_config_new->XMLout($fs_config, OutputFile=>$fh);
    #$cmd = $fs_config_new->XMLout($fs_config);
    #$cmd = undef;
    $cmd = "exec confBilling create: $fs_billing\n";
    system("chown $uid:$gid $fs_billing");
    system("chmod 640 $fs_billing");
    return ($cmd, undef);
}
sub confAcl {
    my ($self) = @_;
    my $cmd = undef;
    my $fs_config = XMLin('<configuration name="acl.conf" description="Network Lists"><network-lists /></configuration>', KeyAttr=>{});
    $fs_config->{'network-lists'}->{list} = \@{$self->{_acl_list}};
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_acl or die "open($fs_acl): $!";
    $fs_config_new->XMLout($fs_config, OutputFile=>$fh);
    #$cmd = $fs_config_new->XMLout($fs_config);
    #$cmd = undef;
    $cmd = "exec confAcl\n";
    return ($cmd, undef);
}
sub confDB {
    my ($self, $name, $action) = @_;
    my $cmd = undef;
    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");
    my $fs_config = XMLin('<configuration name="db.conf" description="LIMIT DB Configuration"><settings /></configuration>', KeyAttr=>{});
    if ($action eq 'delete') {
        #splice(@{$fs_config->{settings}->{param}}, 0, 1); 
        $self->{_odbc_user} = undef
        $self->{_odbc_pass} = undef;
        $self->{_odbc_name} = undef;
        $self->{_odbc_dsn} = undef;
        $self->{_odbc_def} = undef;
    }
    else {
        $self->{_odbc_user} = (defined($config->returnValue("odbc $name user"))) ? $config->returnValue("odbc $name user") : undef;
        $self->{_odbc_pass} = (defined($config->returnValue("odbc $name password"))) ? $config->returnValue("odbc $name password") : undef;
        $self->{_odbc_name} = $name;
        $self->{_odbc_dsn} = $self->{_odbc_name}.':'.$self->{_odbc_user}.':'.$self->{_odbc_pass};
        push @{ $fs_config->{settings}->{param} }, { name => 'odbc-dsn', value => $self->{_odbc_dsn} };
    }
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_db or die "open($fs_db): $!";
    $fs_config_new->XMLout($fs_config, OutputFile=>$fh);
    #$cmd = $fs_config_new->XMLout($fs_config);
    #$cmd = undef;
    $cmd = "exec confDB\n";
    return ($cmd, undef);
}
sub confODBC {
    my ($self) = @_;
    my $cmd = undef;
    my $fs_odbc = $fs_dir.'/.odbc.ini';
    my $config = new Vyatta::Config;
    $config->setLevel("$fsLevel");

    my ($cfg);
    my $sec = 'fs';
    if (-e $fs_odbc) {
        $cfg = Config::IniFiles->new(-file => $fs_odbc);
    }
    else {
        $cfg= Config::IniFiles->new();
        $cfg->SetFileName($fs_odbc);
    }
    if (scalar(@{$self->{_odbc}}) > 0) {
        for my $sec (@{$self->{_odbc}}) {
            if (!$cfg->SectionExists($sec)) {
                $cfg->AddSection($sec);
            }
            my $odbc_mode = (defined($config->returnValue("odbc $sec mode"))) ? $config->returnValue("odbc $sec mode") : undef;
            my $odbc_database = (defined($config->returnValue("odbc $sec database"))) ? $config->returnValue("odbc $sec database") : undef;
            my $odbc_description = (defined($config->returnValue("odbc $sec description"))) ? $config->returnValue("odbc $sec description") : undef;
            my $odbc_host = (defined($config->returnValue("odbc $sec host"))) ? $config->returnValue("odbc $sec host") : undef;
            my $odbc_password = (defined($config->returnValue("odbc $sec password"))) ? $config->returnValue("odbc $sec password") : undef;
            my $odbc_port = (defined($config->returnValue("odbc $sec port"))) ? $config->returnValue("odbc $sec port") : undef;
            my $odbc_user = (defined($config->returnValue("odbc $sec user"))) ? $config->returnValue("odbc $sec user") : undef;
            #my $odbc_ = (defined($config->returnValue("odbc $sec "))) ? $config->returnValue("odbc $sec ") : undef;
            if (defined($odbc_mode) && $odbc_mode eq 'mysql') {
                if ($cfg->exists($sec, 'DATABASE')) {
                    $cfg->setval($sec, 'DATABASE', $odbc_database);
                }
                else {
                    $cfg->newval($sec, 'DATABASE', $odbc_database);
                }
                if ($cfg->exists($sec, 'Description')) {
                    $cfg->setval($sec, 'Description', $odbc_description);
                }
                else {
                    $cfg->newval($sec, 'Description', $odbc_description);
                }
                if ($cfg->exists($sec, 'SERVER')) {
                    $cfg->setval($sec, 'SERVER', $odbc_host);
                }
                else {
                    $cfg->newval($sec, 'SERVER', $odbc_host);
                }
                if ($cfg->exists($sec, 'PASSWORD')) {
                    $cfg->setval($sec, 'PASSWORD', $odbc_password);
                }
                else {
                    $cfg->newval($sec, 'PASSWORD', $odbc_password);
                }
                if ($cfg->exists($sec, 'PORT')) {
                    $cfg->setval($sec, 'PORT', $odbc_port);
                }
                else {
                    $cfg->newval($sec, 'PORT', $odbc_port);
                }
                if ($cfg->exists($sec, 'USER')) {
                    $cfg->setval($sec, 'USER', $odbc_user);
                }
                else {
                    $cfg->newval($sec, 'USER', $odbc_user);
                }
                if ($cfg->exists($sec, 'OPTION')) {
                    $cfg->setval($sec, 'OPTION', '67108864');
                }
                else {
                    $cfg->newval($sec, 'OPTION', '67108864');
                }
                if ($cfg->exists($sec, 'Driver')) {
                    $cfg->setval($sec, 'Driver', 'MySQL');
                }
                else {
                    $cfg->newval($sec, 'Driver', 'MySQL');
                }
            }
            else {
                
            }
        }
    }
    #$cfg->AddSection("ODBC Data Sources");
    #$cfg->WriteConfig();
    $cfg->RewriteConfig();
    system("chown $uid:$gid $fs_odbc");
    system("chmod 640 $fs_odbc");
    $cmd = "exec confODBC\n";
    return ($cmd, undef);
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

sub showODBC {
    my ($self) = @_;
    if (scalar(@{$self->{_odbc}}) > 0) {
        return (join(' ', @{$self->{_odbc}}), undef);
    }
    else {
        return (undef, 'Must specify "odbc"')
    }
}
sub showDomain {
    my ($self) = @_;
    my $config = new Vyatta::Config;
    #$config->setLevel("$fsLevel");
    my $domain_name = (defined($config->returnValue("system domain-name"))) ? $config->returnValue("system domain-name") : 'localhost';
    return $domain_name;
}
sub showCodec {
    my ($self) = @_;
    if (scalar(@{$self->{_codecs}}) > 0) {
        return (join(' ', @{$self->{_codecs}}), undef);
    }
    else {
        return (undef, 'Must specify "codecs"')
    }
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
sub showContext {
    my ($self) = @_;
    if (scalar(@{$self->{_context}}) > 0) {
        return (join(' ', @{$self->{_context}}), undef);
    }
    else {
        return ('default', undef)
    }
}

sub showAcl {
    my ($self) = @_;
    if (defined($self->{_acl})) {
        return ('rfc1918.auto nat.auto localnet.auto loopback.auto '.join(' ', @{$self->{_acls}}), undef);
    }
    else {
        return ('rfc1918.auto nat.auto localnet.auto loopback.auto', undef);
    }
}

1;

