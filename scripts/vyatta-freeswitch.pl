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

my ($conf_name, $show_names, $user_names, $reload_names, $profile_names, $gateway_names, $action, $action_update, $action_delete, $action_create, $action_name, $action_val, $cdr_name);

sub usage {
    print <<EOF;
Usage: $0 --conf=<acl|cli|switch|lang|modules>
       $0 --show=<acl|codecs|lang|allowlang|modules>
       $0 --reload=<xml|dialplan>
       $0 --profile=<name_profile> [--gateway=<name_gateway>] [--action=<create|update|delete>] [--update|--delete|-create=<var_name>]
       $0 --cdr=<name_cdr> [--action=<create|update|delete>] [--update|--delete|-create=<var_name>]
       $0 --user=<name_user>
EOF
    exit 1;
}

GetOptions("conf=s"  => \$conf_name,
       "show=s"	       => \$show_names,
       "reload=s"	       => \$reload_names,
       "profile=s"	       => \$profile_names,
       "gateway=s"	       => \$gateway_names,
       "user=s"	       => \$user_names,
       "cdr=s"	       => \$cdr_name,
       "action=s"	       => \$action,
       "update=s"	       => \$action_update,
       "create=s"	       => \$action_create,
       "delete=s"	       => \$action_delete,
) or usage();
if (!defined($action)) { $action = 'update'; }
if (defined($action_delete)) {
    $action_name = 'delete';
    $action_val = $action_delete;
}
elsif (defined($action_update)) {
    $action_name = 'update';
    $action_val = $action_update;
}
elsif (defined($action_create)) {
    $action_name = 'create';
    $action_val = $action_create;
}
else {
    $action_name = 'update';
}
#show_interfaces($show_names)		if ($show_names);
fs_conf($conf_name, $action) if ($conf_name);
fs_show($show_names) if ($show_names);
fs_profile($profile_names, $action) if ($profile_names && !$gateway_names);
fs_cdr($cdr_name, $action) if ($cdr_name);
fs_gateway($profile_names, $gateway_names, $action, $action_name, $action_val) if ($profile_names && $gateway_names);
exit 0;

sub fs_profile {
    my ($name, $action) = @_;
    #my $name = shift;
    my $config = new Vyatta::FreeSWITCH::Config;
    $config->setup();
    my ($cmd, $err) = $config->get_command() if ($action ne 'delete') ;
    #print "fs_profile\n";    
    if (defined($err)) {
        print STDERR "FreeSWITCH configuration error: $err.\n";
        exit 1;
    }
    my ($res, $er) = $config->confProfile($name, $action);
    if (defined($er)) {
        print STDERR "FreeSWITCH configuration profile error: $er.\n";
        exit 1;
    }
    else {
        print "$res\n";
    }
}
sub fs_gateway {
    my ($profile, $name, $action, $action_name, $action_val) = @_;
    #my $name = shift;
    my $config = new Vyatta::FreeSWITCH::Config;
    $config->setup();
    my ($cmd, $err) = $config->get_command() if ($action ne 'delete') ;
    #print "fs_profile\n";    
    if (defined($err)) {
        print STDERR "FreeSWITCH configuration error: $err.\n";
        exit 1;
    }
    my ($res, $er) = $config->confGateway($name, $profile, $action, $action_name, $action_val);
    if (defined($er)) {
        print STDERR "FreeSWITCH configuration profile error: $er.\n";
        exit 1;
    }
    elsif (defined($res)) {
        print "$res\n";
    }
}
sub fs_cdr {
    my ($name, $action) = @_;
    my $config = new Vyatta::FreeSWITCH::Config;
    $config->setup();
    my ($cmd, $err) = $config->get_command() if ($action ne 'delete') ;
    if (defined($cmd)) {
            my ($res, $err) = $config->confCdr($name, $action);
            $config->confModules();
            if (defined($res)) {
                print $res;
            }
    }
    if (defined($err)) {
        print STDERR "FreeSWITCH configuration error: $err.\n";
    exit 1;
    }
}    
sub fs_conf {
    my ($name, $action) = @_;
    #my $name = shift;
    
    my $config = new Vyatta::FreeSWITCH::Config;
    $config->setup();

    #my $config = new Vyatta::Config;
    #$config->setLevel("service sip");
    my ($cmd, $err) = $config->get_command() if ($action ne 'delete') ;
    
    #if (!defined($self->{_secret_file}) && !defined($self->{_tls_def}));
    #if (!defined($config->returnValue("domain-name"))) {
    #    return (undef, 'Must specify "domain-name"');
    #}
    if (defined($cmd)) {
        if ($name eq 'switch') {
            $config->confSwitch();
        }
        elsif ($name eq 'acl') {
            $config->confAcl();
        }
        elsif ($name eq 'lang') {
            $config->confLanguage();
            $config->confModules();
        }
        elsif ($name eq 'cli') {
            $config->confCli();
            $config->confModules();
        }
        elsif ($name eq 'cdr') {
            #my ($res, $err) = $config->confCdr();
            #print $res;
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
    elsif ($name eq 'context') {
        my $config = new Vyatta::FreeSWITCH::Config;
        $config->setup();
        my ($cmd, $err) = $config->showContext();
        if (defined($err)) {
            print STDERR "\nFreeSWITCH configuration error: $err.\n";
            exit 1;
        }
        else {
            print "$cmd\n";
        }
    }
    elsif ($name eq 'allowcodecs') {
        my $config = new Vyatta::FreeSWITCH::Config;
        $config->setup();
        my ($cmd, $err) = $config->showCodec();
        if (defined($err)) {
            print STDERR "\nFreeSWITCH configuration error: $err.\n";
            exit 1;
        }
        else {
            print "$cmd\n";
        }
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
    elsif ($name eq 'acl') {
        my $config = new Vyatta::FreeSWITCH::Config;
        $config->setup();
        my ($cmd, $err) = $config->showAcl();
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

