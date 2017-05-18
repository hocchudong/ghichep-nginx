# Cấu hình MariaDB replicate với galera và keepalived.

## I. Chuẩn bị.

- Mô hình triển khai :

![galera](/images/galera.png)

- Phân hoạch địa chỉ IP :

![ip-galera](/images/ip-galera.png)

## II. Cài đặt và cấu hình.

- Cấu hình selinux :

    ```sh
    vi /etc/selinux/config
    ```

- Sửa lại dòng sau :

    ```sh
    SELINUX=enforcing

    # Thành :

    SELINUX=disabled
    ```

- Sau đó chạy lệnh sau :

    ```sh
    setenforce 0
    ```


### 1. Cài đặt keepalived trên cả 3 node MariaDB.

- Cài đặt các gói phần mềm hỗ trợ :

    ```sh
    yum install gcc kernel-headers kernel-devel -y
    ```

- Cài đặt keep alive :

    ```sh
    yum install keepalived
    ```

- Dùng trình soạn thảo vi mở file /etc/keepalived/keepalived.conf :

    ```sh
    vi /etc/keepalived/keepalived.conf
    ```

- Tìm và sửa lại các dòng sau :

    ```sh

    vrrp_instance VI_1 {
        state MASTER
        interface eth1
        virtual_router_id 51
        priority 101
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
            10.10.20.169
        }

    ```

- Khởi động dịch vụ :

    ```sh
    service keepalived start chkconfig keepalived on
    ```

- Kiểm tra lại địa chỉ :

    ```sh
    ip addr show eth1
    ```

### 2. Cài đặt MariaDB và cấu hình galera cluster.

#### Trên cả 3 node DB cài đặt.

- Thêm repo galera :

    ```sh
    echo '[mariadb]
    name = MariaDB
    baseurl = http://yum.mariadb.org/10.1/centos7-amd64
    gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
    gpgcheck=1' >> /etc/yum.repos.d/MariaDB.repo
    ```

- Update các gói package :

    ```sh
    yum -y upgrade
    ```

- Cài đặt MariaDB :

    ```sh
    yum -y install mariadb-server rsync xinetd
    ```

- Sao lưu file cấu hình của mariadb :

    ```sh
    cp /etc/my.cnf.d/server.cnf  /etc/my.cnf.d/server.cnf.orig
    ```

- Sửa lại cấu hình lại section [galera] như sau :

    ```sh
    [galera]
    # Mandatory settings
    wsrep_on=ON
    wsrep_provider=/usr/lib64/galera/libgalera_smm.so

    #add your node ips here
    wsrep_cluster_address="gcomm://10.10.20.10,10.10.20.20,10.10.20.30"
    binlog_format=row
    default_storage_engine=InnoDB
    innodb_autoinc_lock_mode=2
    #Cluster name
    wsrep_cluster_name="mysql_cluster"
    # Allow server to accept connections on all interfaces.

    bind-address=0.0.0.0

    # this server ip, change for each server
    wsrep_node_address="10.10.20.10" # Thay đổi địa chỉ trên từng node.

    wsrep_sst_method=rsync
    ```

- Trên node cluster chính chạy dòng sau :

    ```sh
    galera_new_cluster
    ```

- Khởi động mariadb

    ```sh
    systemctl start mariadb
    ```

- Trên các node còn lại join các node vào cluster :

    ```sh
    systemctl start mariadb
    ```

- Kiểm tra cluster running :

    ```sh
    mysql -u root -p -e "SHOW STATUS LIKE 'wsrep_cluster_size'"
    ```

- Đặt mật khẩu `root` cho mariadb :

    ```sh
    mysql_secure_installation
    ```

- Trên 1 node bất kỳ tạo cơ sở dữ liệu :

    ```sh
    mysql -u root -p
    CREATE DATABASE wordpress;
    CREATE USER wordpress@10.10.20.40 IDENTIFIED BY 'wordpress';
    GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@10.10.20.40 IDENTIFIED BY 'wordpress';
    FLUSH PRIVILEGES;
    exit
    ```

### 3. Cài đặt trên node wordpress.

- Cài đặt httpd :

    ```sh
    yum -y install httpd
    ```

- Khởi động httpd :

    ```sh
    systemctl start httpd
    systemctl enable httpd
    ```

- Cài đặt php :

    ```sh
    yum -y install php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap
    ```

- Tải wordpress :

    ```sh
    wget https://wordpress.org/latest.zip
    ```

- Giải nén :

    ```sh
    unzip latest.zip
    ```

- Sao chép vào thư mục /var/www/html :

    ```sh
    chmod -R 775 /var/www/html/wordpress
    ```

- Chuyển tới thư mục :

    ```sh
    cd /var/www/html/wordpress
    ```

- Sao chép file cấu hình wordpress :

    ```sh
    cp wp-config-sample.php wp-config.php
    ```

- Mở file config :

    ```sh
    vi wp-config.php
    ```

- Sửa lại file cấu hình :

    ```sh
    // ** MySQL settings - You can get this info from your web host ** //
    /** The name of the database for WordPress */
    define('DB_NAME', 'wordpress');

    /** MySQL database username */
    define('DB_USER', 'wordpress');

    /** MySQL database password */
    define('DB_PASSWORD', 'wordpress');
    /** MySQL database host */
    define('DB_HOST', '10.10.10.169')
    ```

- Khởi động lại httpd :

    ```sh
    systemctl restart httpd
    ```

- Truy cập vào địa chỉ để kiểm tra :

    ```sh
    10.10.20.40/wordpress/wp-admin/install.php
    ```

- Chúng ta tiến hành tắt các server DB đi để kiểm tra .
