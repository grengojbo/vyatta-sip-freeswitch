package Vyatta::FreeSWITCH::TestConfig;
use strict;
use lib "/opt/vyatta/share/perl5/";
#use Vyatta::Config;
#use Vyatta::TypeChecker;
#use NetAddr::IP;

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

my %modules_cdr_hash = (
    'xml' => 'xml_cdr',
    'json' => 'json_cdr',
    'radius' => 'radius_cdr',
    'csv' => 'cdr_csv',
    'sqlite' => 'cdr_sqlite',
    'postgresql' => 'cdr_pg_csv',
);
my %fields = (
  _cdr_xml      => undef,
  _is_empty      => 1,
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
  return 0;
}

sub confModules {
    my ($self, $name) = @_;
    my $mod_name = "mod_$name";
    my $fs_config = XMLin($fs_modules);
    #print Dumper($fs_config);
    foreach my $key (@{$fs_config->{modules}->{load}}) {
        if ($key->{module} eq $mod_name) {
            return 1;
        } 
    }
    return undef;
}

sub confCdr {
    my ($self, $name, $param) = @_;
    my $fs_cdr = $fs_conf_dir.'/autoload_configs/'.$modules_cdr_hash{$name}.'.conf.xml';
    my $fs_config = XMLin($fs_cdr);
    #print Dumper($fs_config);
    return $fs_config->{settings}->{param}->{$param}->{value};
}
sub confDB {
    my ($self, $name, $param) = @_;
    my $fs_config = XMLin($fs_db);
    return $fs_config->{settings}->{param}->{value};
}

sub confCli {
    my ($self, $param) = @_;
    my $fs_config = XMLin($fs_event_socket);
    return $fs_config->{settings}->{param}->{$param}->{value};
}

sub confAcl {
    my ($self, $name, $param) = @_;
    my $fs_config = XMLin($fs_acl, KeyAttr => {});
    #print "$fs_acl\n";
    #    return $fs_config->{'network-lists'}->{list}->{$name}->{dafault};
    #}
    #else {
        foreach my $key (@{$fs_config->{'network-lists'}->{list}}) {
            if ($key->{name} eq $name) {
                if ($param eq 'default') {
                    return $key->{default};
                }
                else {
                    foreach my $k (@{$key->{node}}) {
                        if ($k->{cidr} eq $param) {
                            return $k->{'type'};
                        }
                    }
                }
    #        if ($key->{cidr} eq $param) {
    #            return $key->{type};
            } 
        } 
    #}
    #return undef;
}

1;
