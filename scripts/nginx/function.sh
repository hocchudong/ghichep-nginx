#!/bin/bash -ex

# Ham dinh nghia mau cho cac ban tin in ra man hinh
function echocolor {
    echo "$(tput setaf 3)##### $1 #####$(tput sgr0)"
}


# Ham sua file cau hinh cua 
function ops_edit {
    crudini --set $1 $2 $3 $4
}

# Cach dung
## Cu phap:
##			ops_edit_file $bien_duong_dan_file [SECTION] [PARAMETER] [VALUAE]
## Vi du:
###			filekeystone=/etc/keystone/keystone.conf
###			ops_edit_file $filekeystone DEFAULT rpc_backend rabbit


# Ham de del mot dong trong file cau hinh
function ops_del {
    crudini --del $1 $2 $3
}