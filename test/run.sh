#!/bin/vbash
#sudo make install && ./test/run.sh && sudo ./test/t.p
/opt/vyatta/sbin/my_delete service sip cdr
/opt/vyatta/sbin/my_commit
/opt/vyatta/sbin/my_set service sip cdr csv
#/opt/vyatta/sbin/my_set service sip cdr radius
/opt/vyatta/sbin/my_set service sip cdr xml
/opt/vyatta/sbin/my_commit
#/opt/vyatta/sbin/my_delete service sip cdr csv
#/opt/vyatta/sbin/my_delete service sip cdr radius
#/opt/vyatta/sbin/my_commit
