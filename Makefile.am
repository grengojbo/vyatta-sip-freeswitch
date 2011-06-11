cfgdir		 = $(datadir)/vyatta-cfg/templates
opdir		 = $(datadir)/vyatta-op/templates
share_perl5dir	 = $(datarootdir)/perl5/Vyatta/FreeSWITCH
bin_sudo_usersdir = $(bindir)/sudo-users
curverdir = $(sysconfdir)/freeswitch

bin_SCRIPTS = scripts/vyatta-show-interfaces2.pl
sbin_SCRIPTS = scripts/vyatta-freeswitch.pl
sbin_SCRIPTS += scripts/vyatta-freeswitch-vars

share_perl5_DATA = lib/Vyatta/FreeSWITCH/Config.pm
share_perl5_DATA += lib/Vyatta/FreeSWITCH/TestConfig.pm
curver_DATA = conf/internal.xml
curver_DATA += conf/internal-ipv6.xml
curver_DATA += conf/external.xml
curver_DATA += conf/context_default.xml
curver_DATA += conf/context_public.xml
curver_DATA += conf/context_local.xml
curver_DATA += conf/extension_local.xml
curver_DATA += conf/extension.xml

cpiop = find  . ! -regex '\(.*~\|.*\.bak\|.*\.swp\|.*\#.*\#\)' -print0 | \
  cpio -0pd

install-exec-hook:
	mkdir -p $(DESTDIR)$(cfgdir)
	cd templates-cfg; $(cpiop) $(DESTDIR)$(cfgdir)
	mkdir -p $(DESTDIR)$(opdir)
	cd templates-op; $(cpiop) $(DESTDIR)$(opdir)

