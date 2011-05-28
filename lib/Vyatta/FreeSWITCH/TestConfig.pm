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
my $fs_profile_dir = $fs_conf_dir.'/sip_profiles';
my $fs_example_dir = '/opt/vyatta/etc/freeswitch';

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
        #print "$key->{module}=$mod_name\n";
        if ($key->{module} eq $mod_name) {
            return 1;
        } 
    }
    return undef;
}

1;
