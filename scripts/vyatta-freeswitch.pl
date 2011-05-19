#!/usr/bin/perl
#
# Module: vyatta-freeswitch.pl
# 
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
# A copy of the GNU General Public License is available as
# `/usr/share/common-licenses/GPL' in the Debian GNU/Linux distribution
# or on the World Wide Web at `http://www.gnu.org/copyleft/gpl.html'.
# You can also obtain it by writing to the Free Software Foundation,
# Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
# MA 02110-1301, USA.
# 
# This code was originally developed by Vyatta, Inc.
# Portions created by Vyatta are Copyright (C) 2007 Vyatta, Inc.
# All Rights Reserved.
# 
# Author: Stig Thormodsrud
# Date: November 2007
# Description: Script to assign addresses to interfaces.
# 
# **** End License ****
#

use lib "/opt/vyatta/share/perl5/";
use Vyatta::Config;
use Vyatta::Interface;

use Getopt::Long;
use POSIX;

use XML::Simple;
use Data::Dumper;

use strict;
use warnings;

my $fs_conf_dir = '/opt/freeswitch/conf';

my ($conf_name, $show_names);

sub usage {
    print <<EOF;
Usage: $0 --conf=<conf_name>
       $0 --show=<type>
EOF
    exit 1;
}

GetOptions("conf=s"  => \$conf_name,
       "show=s"	       => \$show_names,
) or usage();

#show_interfaces($show_names)		if ($show_names);
fs_conf($conf_name) if ($conf_name);
exit 0;

sub fs_conf_switch {
    my $config = new Vyatta::Config;
    #$config->setLevel("system");
    #print $config->returnValue("domain-name");
    $config->setLevel("service sip");
    my $fs_switch = $fs_conf_dir.'/autoload_configs/switch.conf.xml';
    my $fs_config = XMLin($fs_switch, KeyAttr=>{params=>"+names"});
    #print Dumper($fs_config);
    foreach my $key (@{$fs_config->{settings}->{param}}) {
        if ($key->{name} eq 'dump-cores') {
            $key->{value}=$config->returnValue("dump-cores");
        }
        elsif ($key->{name} eq 'loglevel') {
            $key->{value}=$config->returnValue("loglevel");
        }
        elsif ($key->{name} eq 'max-sessions') {
            $key->{value}=$config->returnValue("max-sessions");
        }
        elsif ($key->{name} eq 'sessions-per-second') {
            $key->{value}=$config->returnValue("sessions-per-second");
        }
        elsif ($key->{name} eq 'rtp-enable-zrtp') {
            $key->{value}=$config->returnValue("zrtp-secure-media");
        }
        
    }
    my $fs_config_new = XML::Simple->new(rootname=>'configuration');
    open my $fh, '>:encoding(UTF-8)', $fs_switch or die "open($fs_switch): $!";
    $fs_config_new->XMLout($fs_config, OutputFile=>$fh);
    #print $fs_config_new->XMLout($fs_config, xmldecl=>'<?xml version="1.0">');
}

sub fs_conf_language {
    my $config = new Vyatta::Config;
    $config->setLevel("service sip");
    my @tmp = $config->returnValues('language');
    if (scalar(@tmp) > 0) {
      for my $rem (@tmp) {
        print $rem;
      }
    }
    print join(",",@tmp)
    #if (scalar(@{$self->{_remote_host}}) > 0) {
    #  for my $rem (@{$self->{_remote_host}}) {
    #    return (undef, '"remote-address" cannot be the same as "remote-host"')
    #      if ($rem eq $self->{_remote_addr});
    #  }
    #}
    
    
}

sub fs_conf {
    my $name = shift;
    my $config = new Vyatta::Config;
    $config->setLevel("service sip");
    #if (!defined($self->{_secret_file}) && !defined($self->{_tls_def}));
    if (!defined($config->returnValue("domain-name"))) {
        return (undef, 'Must specify "domain-name"');
    }
    if ($name eq 'switch') {
        fs_conf_switch();
    }
    elsif ($name eq 'lang') {
        fs_conf_language();
    }
    elsif ($name eq 'acl') {
        fs_conf_switch();
    }
}

