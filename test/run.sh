#!/bin/vbash
#sudo make install && ./test/run.sh && sudo ./test/t.pl
/opt/vyatta/sbin/my_delete service sip cdr
/opt/vyatta/sbin/my_delete service sip acl
/opt/vyatta/sbin/my_delete service sip odbc
/opt/vyatta/sbin/my_delete service sip db
/opt/vyatta/sbin/my_commit
# CDR
/opt/vyatta/sbin/my_set service sip cdr csv
#/opt/vyatta/sbin/my_set service sip cdr radius
/opt/vyatta/sbin/my_set service sip cdr xml url http://example.com/cdr/ 
/opt/vyatta/sbin/my_set service sip cdr xml auth-scheme basic
/opt/vyatta/sbin/my_set service sip cdr xml username test
/opt/vyatta/sbin/my_set service sip cdr xml password test 
/opt/vyatta/sbin/my_set service sip cdr xml retries 5 
/opt/vyatta/sbin/my_set service sip cdr xml err-log-dir /opt/freeswitch/log/xml_cdr
/opt/vyatta/sbin/my_set service sip cdr xml delay 10
/opt/vyatta/sbin/my_commit
sudo ./test/t.pl --conf=cdr
# ACL
/opt/vyatta/sbin/my_set service sip acl mylan default deny
/opt/vyatta/sbin/my_set service sip acl lans default deny
/opt/vyatta/sbin/my_set service sip acl mylan address 192.168.10.0/24 action allow
/opt/vyatta/sbin/my_set service sip acl mylan address 192.168.10.20/32 action deny
/opt/vyatta/sbin/my_set service sip acl mylan address 192.168.20.0/24
/opt/vyatta/sbin/my_commit
sudo ./test/t.pl --conf=acl
# ODBC
/opt/vyatta/sbin/my_set service sip odbc testdb mode mysql
/opt/vyatta/sbin/my_set service sip odbc testdb database testdb
/opt/vyatta/sbin/my_set service sip odbc testdb password test
/opt/vyatta/sbin/my_set service sip odbc testdb port 3306
/opt/vyatta/sbin/my_set service sip odbc testdb user test
/opt/vyatta/sbin/my_set service sip odbc testdb host localhost
/opt/vyatta/sbin/my_commit
sudo ./test/t.pl --conf=odbc
/opt/vyatta/sbin/my_set service sip db default testdb
/opt/vyatta/sbin/my_commit
sudo ./test/t.pl --conf=db
#/opt/vyatta/sbin/my_set 
#/opt/vyatta/sbin/my_commit
#/opt/vyatta/sbin/my_delete service sip cdr csv
#/opt/vyatta/sbin/my_delete service sip cdr radius
#/opt/vyatta/sbin/my_commit
