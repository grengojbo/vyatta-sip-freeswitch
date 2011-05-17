package Vyatta::FreeSWITCH::Config;

use strict;
use lib "/opt/vyatta/share/perl5/";
use Vyatta::Config;
use Vyatta::TypeChecker;
use NetAddr::IP;

#my $ccd_dir = '/opt/vyatta/etc/openvpn/ccd';
#my $status_dir = '/opt/vyatta/etc/openvpn/status';
#my $status_itvl = 30;
#my $ping_itvl = 10;
#my $ping_restart = 60;

my %fields = (
  _areacode     => undef,
  _country      => undef,
  _domain_name  => undef,
  _language     => undef,
  _=> [],
  _loglevel     => undef,
  _max_sessions => undef,
  _mode         => undef,
  _modules      => undef,
  _multiple_registrations => undef,
  _sessions_per_second    => undef,
  _tls_ca        => undef,
  _tls_cert      => undef,
  _tls_key       => undef,
  _tls_dh        => undef,
  _tls_crl       => undef,
  _tls_role      => undef,
  _profile       => [],
  _user          => [],
  _zrtp_secure_media => undef,
  _=> undef,
  _is_empty         => 1,
);

1;

