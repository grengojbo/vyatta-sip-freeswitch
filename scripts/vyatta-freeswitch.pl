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

sub usage {
    print <<EOF;
Usage: $0 --dev=<interface> --check=<type>
       $0 --dev=<interface> --warn
       $0 --dev=<interface> --valid-mac=<aa:aa:aa:aa:aa:aa>
       $0 --dev=<interface> --valid-addr-commit={addr1 addr2 ...}
       $0 --dev=<interface> --speed-duplex=speed,duplex
       $0 --dev=<interface> --check-speed=speed,duplex
       $0 --dev=<interface> --allowed-speed
       $0 --dev=<interface> --isup
       $0 --show=<type>
EOF
    exit 1;
}
my $fs_conf_dir = '/opt/freeswitch/conf/freeswitch.xml';
my $fs_config_new = XML::Simple->new(rootname=>'document',);
my $fs_config = XMLin($fs_conf_dir);
#print Dumper($fs_config);
#print $fs_config->{section}->{directory}
#$fs_config_new->XMLout($fs_config, xmldecl=>'<?xml version="1.0">');
my $t = $fs_config->{section}->{languages}->{'X-PRE-PROCESS'}->[1];
print $t->{data};

