cfgdir		 = $(datadir)/vyatta-cfg/templates
opdir		 = $(datadir)/vyatta-op/templates
share_perl5dir	 = $(datarootdir)/perl5/Vyatta/FreeSWITCH
bin_sudo_usersdir = $(bindir)/sudo-users
curverdir = $(sysconfdir)/freeswitch

sbin_SCRIPTS = scripts/vyatta-freeswitch.pl
sbin_SCRIPTS += scripts/vyatta-freeswitch-vars

share_perl5_DATA = lib/Vyatta/FreeSWITCH/Config.pm
curver_DATA = conf/internal.xml
curver_DATA += conf/internal-ipv6.xml
curver_DATA += conf/external.xml

cpiop = find  . ! -regex '\(.*~\|.*\.bak\|.*\.swp\|.*\#.*\#\)' -print0 | \
  cpio -0pd

install-exec-hook:
	mkdir -p $(DESTDIR)$(cfgdir)
	cd templates-cfg; $(cpiop) $(DESTDIR)$(cfgdir)
	mkdir -p $(DESTDIR)$(opdir)
	cd templates-op; $(cpiop) $(DESTDIR)$(opdir)

