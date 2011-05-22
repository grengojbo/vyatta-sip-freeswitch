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
# Author: Oleg Dolya
# Date: May 2011
# Description: FreeSWITCH configuration script.
# 
# **** End License ****
#

use lib "/opt/vyatta/share/perl5/";
use Vyatta::Config;
use Vyatta::Interface;
use Vyatta::FreeSWITCH::Config;

use Getopt::Long;
use POSIX;


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
fs_show($show_names) if ($show_names);
exit 0;

sub fs_conf {
    my $name = shift;
    
    my $config = new Vyatta::FreeSWITCH::Config;
    $config->setup();

    #my $config = new Vyatta::Config;
    #$config->setLevel("service sip");
    
    my ($cmd, $err) = $config->get_command();
    
    #if (!defined($self->{_secret_file}) && !defined($self->{_tls_def}));
    #if (!defined($config->returnValue("domain-name"))) {
    #    return (undef, 'Must specify "domain-name"');
    #}
    if (defined($cmd)) {
        if ($name eq 'switch') {
            $config->confSwitch();
        }
        elsif ($name eq 'acl') {
            $config->confSwitch();
        }
        elsif ($name eq 'lang') {
            $config->confLanguage();
            $config->confModules();
        }
        elsif ($name eq 'cli') {
            $config->confCli();
            $config->confModules();
        }
        elsif ($name eq 'modules') {
            $config->confModules();
        }
    }
    if (defined($err)) {
        print STDERR "FreeSWITCH configuration error: $err.\n";
    exit 1;
    }
}
sub fs_show {
    my $name = shift;
    if ($name eq 'modules') {
        Vyatta::FreeSWITCH::Config::show_modules();
    }
    elsif ($name eq 'lang') {
        Vyatta::FreeSWITCH::Config::show_languages();
    }
    elsif ($name eq 'codecs') {
        Vyatta::FreeSWITCH::Config::show_codecs();
    }
    elsif ($name eq 'allowlang') {
        my $config = new Vyatta::FreeSWITCH::Config;
        $config->setup();
        my ($cmd, $err) = $config->showLanguage();
        if (defined($err)) {
            print STDERR "\nFreeSWITCH configuration error: $err.\n";
            exit 1;
        }
        else {
            print "$cmd\n";
        }
    }
}
exit 0;

