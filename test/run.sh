#!/bin/vbash
#sudo make install && ./test/run.sh && sudo ./test/t.pl
run_delete() {
/opt/vyatta/sbin/my_delete service sip cdr
/opt/vyatta/sbin/my_delete service sip acl
/opt/vyatta/sbin/my_delete service sip odbc
/opt/vyatta/sbin/my_delete service sip db
/opt/vyatta/sbin/my_commit
}
# BASE
set_base() {
/opt/vyatta/sbin/my_set service sip mode pbx
/opt/vyatta/sbin/my_set service sip language en
/opt/vyatta/sbin/my_set service sip language ru
/opt/vyatta/sbin/my_set service sip default-language ru
/opt/vyatta/sbin/my_set service sip country UA
/opt/vyatta/sbin/my_set service sip areacode 380
/opt/vyatta/sbin/my_set service sip codecs ilbc
/opt/vyatta/sbin/my_set service sip codecs speex
/opt/vyatta/sbin/my_set service sip codecs pcma
/opt/vyatta/sbin/my_set service sip domain-name example.com
/opt/vyatta/sbin/my_set service sip dialplan context public
}
# modules
set_modules() {
/opt/vyatta/sbin/my_set service sip modules conference
}
# ACL
set_acl() {
/opt/vyatta/sbin/my_set service sip acl mylan default deny
/opt/vyatta/sbin/my_set service sip acl lans default deny
/opt/vyatta/sbin/my_set service sip acl mylan address 192.168.10.0/24 action allow
/opt/vyatta/sbin/my_set service sip acl mylan address 192.168.10.20/32 action deny
/opt/vyatta/sbin/my_set service sip acl mylan address 192.168.20.0/24
}
set_cli() {
/opt/vyatta/sbin/my_set service sip cli listen-address 127.0.0.1
/opt/vyatta/sbin/my_set service sip cli listen-port 5021
/opt/vyatta/sbin/my_set service sip cli password 123
#/opt/vyatta/sbin/my_set service sip cli apply-inbound-acl lans
#/opt/vyatta/sbin/my_set service sip cli acl lans
}
# CDR
set_cdr() {
/opt/vyatta/sbin/my_set service sip cdr csv
#/opt/vyatta/sbin/my_set service sip cdr radius
/opt/vyatta/sbin/my_set service sip cdr xml url http://example.com/cdr/ 
/opt/vyatta/sbin/my_set service sip cdr xml auth-scheme basic
/opt/vyatta/sbin/my_set service sip cdr xml username test
/opt/vyatta/sbin/my_set service sip cdr xml password test 
/opt/vyatta/sbin/my_set service sip cdr xml retries 5 
/opt/vyatta/sbin/my_set service sip cdr xml err-log-dir /opt/freeswitch/log/xml_cdr
/opt/vyatta/sbin/my_set service sip cdr xml delay 10
}
# Profile
set_profile() {
/opt/vyatta/sbin/my_set service sip profile internal mode internal
/opt/vyatta/sbin/my_set service sip profile internal address 192.168.67.67
/opt/vyatta/sbin/my_set service sip profile internal codec inbound pcma
#/opt/vyatta/sbin/my_set service sip profile external mode external
#/opt/vyatta/sbin/my_set service sip profile external codec inbound pcma
#/opt/vyatta/sbin/my_set 
}

# ODBC
set_odbc() {
/opt/vyatta/sbin/my_set service sip odbc testdb mode mysql
/opt/vyatta/sbin/my_set service sip odbc testdb database testdb
/opt/vyatta/sbin/my_set service sip odbc testdb password test
/opt/vyatta/sbin/my_set service sip odbc testdb port 3306
/opt/vyatta/sbin/my_set service sip odbc testdb user test
/opt/vyatta/sbin/my_set service sip odbc testdb host localhost
}
set_db() {
/opt/vyatta/sbin/my_set service sip db default testdb
}
set_gateway(){
/opt/vyatta/sbin/my_set service sip profile external gateway voip-provider mode trunk
/opt/vyatta/sbin/my_commit service sip profile external gateway voip-provider realm sip.089.com.ua
/opt/vyatta/sbin/my_commit set service sip profile external gateway voip-provider from-domain 192.168.123.36
/opt/vyatta/sbin/my_commit service sip profile external gateway voip-provider extension SBC
/opt/vyatta/sbin/my_commit service sip profile external gateway voip-provider extension-in-contact true

#/opt/vyatta/sbin/my_commit service sip profile external gateway voip-provider expire-seconds 50
#/opt/vyatta/sbin/my_commit service sip profile external gateway voip-provider retry-seconds 90
#/opt/vyatta/sbin/my_commit
}
run_commit() {
/opt/vyatta/sbin/my_commit
}
test_all() {
sudo ./test/t.pl --conf=acl
sudo ./test/t.pl --conf=cdr
sudo ./test/t.pl --conf=odbc
sudo ./test/t.pl --conf=db
sudo ./test/t.pl --conf=cli
sudo ./test/t.pl --conf=gateway
}
#/opt/vyatta/sbin/my_set 
#/opt/vyatta/sbin/my_commit
#/opt/vyatta/sbin/my_delete service sip cdr csv
#/opt/vyatta/sbin/my_delete service sip cdr radius
#/opt/vyatta/sbin/my_commit
case "$1" in
    test)
        test_all
        ;;
    cli)
        set_:cli
        ;;
    gateway)
        set_gateway
        ;;
    db)
        set_db
        ;;
    modules)
        set_modules
        ;;
    base)
        set_base
        ;;
    profile)
        set_profile
        ;;
    cdr)
        set_cdr
        ;;
    acl)
        set_acl
        ;;
    odbc)
        set_odbc
        ;;
    set-all)
        set_base
        set_acl
        set_cdr
        #set_odbc
        #set_db
        #set_profile
        ;;
    delete)
        run_delete
        ;;
    *)
        echo $"Usage sudo make install && $0 {set-all|test|delete|base|db|cdr|acl|odbc|profile|gateway|modules}"
        exit 1
esac

exit $?

