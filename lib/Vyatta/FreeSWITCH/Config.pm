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

my $uid = 'freeswitch';
my $gid = 'daemon';
my $fs_dir = '/opt/freeswitch';
my $fs_conf_dir = '/opt/freeswitch/conf';
my $fs_fs = $fs_conf_dir.'/freeswitch.xml';
my $fs_modules = $fs_conf_dir.'/autoload_configs/modules.conf.xml';
my $fs_switch = $fs_conf_dir.'/autoload_configs/switch.conf.xml';
my $fs_event_socket = $fs_conf_dir.'/autoload_configs/event_socket.conf.xml';
my $fs_acl = $fs_conf_dir.'/autoload_configs/acl.conf.xml';
my $fs_profile_dir = $fs_conf_dir.'/sip_profiles';
my $fs_example_dir = '/opt/vyatta/etc/freeswitch';
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
  _cli_password => undef,
  #_cli_acl      => undef,
  _acl          => undef,
  _profile_name => undef,
  _acls         => [],
  _acl_list     => [],
  _codecs       => [],
  _profile      => [],
  _gateway      => [],
  _user         => [],
  _language     => [],
  _modules      => [],
  _context      => [],
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
  my @tmp_context = $config->returnValues('dialplan context');
  $self->{_context} = \@tmp_context;
  $self->{_multiple_registrations} = $config->returnValue('multiple-registrations');
  my @tmp_profile = $config->returnValues('profile');
  $self->{_profile} = \@tmp_profile;
  $self->{_sessions_per_second} = $config->returnValue('sessions-per-second');
  $self->{_zrtp_secure_media} = $config->returnValue('zrtp-secure-media');
  my @tmp_user = $config->returnValues('_user');
  $self->{_user} = \@tmp_user;
  my @tmp_acls = $config->listNodes('acl');
  $self->{_acls} = \@tmp_acls;
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
            chown $uid, $gid, $fs_gateway_dir;
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
        #$cmd = "Create Gateway: $fs_gateway\n";
        $cmd = undef;
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
        $cmd = "Delete profile: $name\n";
        return ($cmd, undef);
    }
    else {
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
        if (defined($config->returnValue("profile $name codec transcoding")) && $config->returnValue("profile $name codec transcoding") eq 'diable') {
            $disable_transcoding = 'true';
        }
        my $challenge_realm = (defined($config->returnValue("profile $name auth challenge-realm"))) ? $config->returnValue("profile $name auth challenge-realm") : 'auto_from';
        my $log_auth_failures = (defined($config->returnValue("profile $name auth log-auth-failures"))) ? $config->returnValue("profile $name auth log-auth-failures") : 'true';
        my $accept_blind_auth = (defined($config->returnValue("profile $name auth accept-blind-auth"))) ? $config->returnValue("profile $name auth accept-blind-auth") : undef;
        my $auth_all_packets = (defined($config->returnValue("profile $name auth all-packets"))) ? $config->returnValue("profile $name auth all-packets") : 'false';
        my $auth_calls = (defined($config->returnValue("profile $name auth calls"))) ? $config->returnValue("profile $name auth calls") : 'true';
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
        if ($action eq 'create' && $mode eq 'internal') {
            $auth_all_packets = 'false';
            $auth_calls = 'true';
        }
        elsif ($action eq 'create' && $mode eq 'external') {
            $auth_all_packets = 'false';
            $auth_calls = 'false';
        }
 
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
        if (scalar(@{$self->{_gateway}}) > 0) {
            $fs_config->{gateways}->{name} = "X-PRE-PROCESS";
            $fs_config->{gateways}->{cmd} = "include";
            $fs_config->{gateways}->{data} = "$name/*.xml";
        }
        foreach my $fs (@{$fs_config->{settings}->{param}}) {
            if ($fs->{name} eq 'sip-ip') { $fs->{value} = $address; }
            elsif ($fs->{name} eq 'rtp-ip') { $fs->{value} = $rtp_ip; }
            elsif ($fs->{name} eq 'ext-rtp-ip') { $fs->{value} = $ext_rtp_ip; }
            elsif ($fs->{name} eq 'ext-sip-ip') { $fs->{value} = $ext_sip_ip; }
            elsif ($fs->{name} eq 'sip-port') { $fs->{value} = $config->returnValue("profile $name port"); }
            elsif ($fs->{name} eq 'context') { $fs->{value} = $context; }
            elsif ($fs->{name} eq 'log-auth-failures') { $fs->{value} = $log_auth_failures; }
            elsif ($fs->{name} eq 'challenge-realm') { $fs->{value} = $challenge_realm; }
            elsif ($fs->{name} eq 'accept-blind-auth') {
                $fs->{value} = $accept_blind_auth; 
                $accept_blind_auth_def = 1;
            }
            elsif ($fs->{name} eq 'auth-all-packets') { $fs->{value} = $auth_all_packets; }
            elsif ($fs->{name} eq 'auth-calls') { $fs->{value} = $auth_calls; }
            elsif ($fs->{name} eq 'disable-transcoding') { 
                $fs->{value} = $disable_transcoding; 
                $disable_transcoding_def = 1;
            }
            elsif ($fs->{name} eq 'bitpacking' && defined($bitpacking)) { 
                $fs->{value} = $bitpacking;
                $bitpacking_def = 1;
            }
            elsif ($fs->{name} eq 'inbound-codec-prefs') { $fs->{value} = $inbound_codec_prefs; }
            elsif ($fs->{name} eq 'outbound-codec-prefs') { $fs->{value} = $outbound_codec_prefs; }
            elsif ($fs->{name} eq 'inbound-codec-negotiation') { $fs->{value} = $inbound_codec_negotiation; }
            elsif ($fs->{name} eq 'inbound-late-negotiation') {
                $fs->{value} = $inbound_late_negotiation;
                $inbound_late_negotiation_def = 1;
            }
            elsif ($fs->{name} eq 'local-network-acl') {
                $fs->{value} = $local_network_acl;
                $local_network_acl_def = 1;
            }
            elsif ($fs->{name} eq 'apply-inbound-acl') {
                $fs->{value} = $apply_inbound_acl;
                $apply_inbound_acl_def = 1;
            }
            elsif ($fs->{name} eq 'apply-register-acl') {
                $fs->{value} = $apply_register_acl;
                $apply_register_acl_def = 1;
            }
            elsif ($fs->{name} eq 'apply-proxy-acl') {
                $fs->{value} = $apply_proxy_acl;
                $apply_proxy_acl_def = 1;
            }
            #elsif ($fs->{name} eq '') { $fs->{value} = $; }
        }
        push @{ $fs_config->{settings}->{param} }, {name => 'apply-inbound-acl', value => $apply_inbound_acl } if (defined($apply_inbound_acl) && !defined($apply_inbound_acl_def));
        push @{ $fs_config->{settings}->{param} }, {name => 'apply-register-acl', value => $apply_register_acl } if (defined($apply_register_acl) && !defined($apply_register_acl_def));
        push @{ $fs_config->{settings}->{param} }, {name => 'apply-proxy-acl', value => $apply_proxy_acl } if (defined($apply_proxy_acl) && !defined($apply_proxy_acl_def));
        push @{ $fs_config->{settings}->{param} }, {name => 'local-network-acl', value => $local_network_acl } if (defined($local_network_acl) && !defined($local_network_acl_def));
        push @{ $fs_config->{settings}->{param} }, { name => 'accept-blind-auth', value => $accept_blind_auth } if (defined($accept_blind_auth) && !defined($accept_blind_auth_def));
        push @{ $fs_config->{settings}->{param} }, { name => 'disable-transcoding', value => $disable_transcoding } if (!defined($disable_transcoding_def));
        push @{ $fs_config->{settings}->{param} }, { name => 'bitpacking', value => $bitpacking } if (defined($bitpacking) && !defined($bitpacking_def));
        push @{ $fs_config->{settings}->{param} }, { name => 'inbound-late-negotiation', value => $inbound_late_negotiation } if (defined($inbound_late_negotiation) && !defined($inbound_late_negotiation_def));
        #push @{ $fs_config->{settings}->{param} }, { name => '', value => $ } if (defined($) && !defined($));
        my $fs_config_new = XML::Simple->new(rootname=>'profile');
        #open my $fh, '>:encoding(UTF-8)', $fs_profile or die "open($fs_profile): $!";
        #$fs_config_new->XMLout($fs_config, OutputFile => $fh);
        $cmd = $fs_config_new->XMLout($fs_config);
        return ($cmd, undef);
    }
    
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

sub confAcl {
    my ($self) = @_;
    print "exec confAcl\n";
    my $fs_config = XMLin('<configuration name="acl.conf" description="Network Lists"><network-lists /></configuration>', KeyAttr=>{});
    $fs_config->{'network-lists'}->{list} = \@{$self->{_acl_list}};
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_switch or die "open($fs_switch): $!";
    $fs_config_new->XMLout($fs_config, OutputFile=>$fh);
    #print $fs_config_new->XMLout($fs_config);
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

