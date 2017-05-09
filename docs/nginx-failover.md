# Thực hiện bài lab Nginx Failover.

## I. Mô hình.

## II. Cài đặt và cấu hình.

### 1. Trên các node Load Balancing.

- Thêm repo nginx:

  ```sh
  yum install epel-release
  ```

- Cài đặt nginx :

    ```sh
    yum install nginx

    ```

- Khởi động nginx :

    ```sh
    systemctl start nginx
    ```

- Khởi động `firewall-cmd` :

    ```sh
    systemctl start firewalld
    systemctl enable firewalld
    ```

- Cấu hình firewall  và restart lại dịch vụ:

    ```sh
    sudo firewall-cmd --permanent --zone=public --add-service=http 
    sudo firewall-cmd --permanent --zone=public --add-service=https
    sudo firewall-cmd --reload

    ```

- Dùng trình soạn thảo `vi` mở file `/etc/nginx/nginx.conf` :

    ```sh
    vi /etc/nginx/nginx.conf
    ```

- Tìm và comment dòng sau :

    ```sh
    # listen       [::]:80 default_server;
    ```

- Chuyển đến thư mục `conf.d` của Nginx  :

    ```sh
    cd /etc/nginx/conf.d
    ```

- Tại ra 2 file là `lbapache.conf` và `lbnginx.conf` :

    ```sh
    touch lbapache.conf
    touch lbnginx.conf
    ```

- Mở file `lbapache.conf` và thêm vào nội dung sau :

    ```sh
    upstream lbapache {
        server 10.10.20.10:81;
        server 10.10.20.20:81;
    }
    
    server {
        listen 81;
        server_name _;
        location / {
            proxy_pass http://lbapache;
        }
    }

    ```

- Mở file `lbnginx.conf` và thêm vào nội dung sau :

    ```sh
    upstream lbnginx {
        server 10.10.20.10:80;
        server 10.10.20.20:80;
    }
    
    server {
        listen 82;
        server_name _;
        location / {
            proxy_pass http://lbnginx;
        }
    }

    ```

- Mở port 81 và 82 :


    ```sh
    firewall-cmd --zone=public --add-port=81/tcp
    firewall-cmd --zone=public --add-port=82/tcp
    ```

- Restart lai dịch vụ :

    ```sh
    systemctl restart nginx
    ```

- Nếu như có lỗi xảy ra do SElinux chúng ta thực hiện các lệnh sau để sửa lỗi :

    ```sh
    yum install -y policycoreutils-devel

    grep nginx /var/log/audit/audit.log | audit2allow -M nginx

    semodule -i nginx.pp
    ```

- Sau đó restart lại dịch vụ :

    ```sh
    systemctl restart nginx
    ```

### 2. Trên các node web server .

- Thêm repo nginx:

  ```sh
  yum install epel-release
  ```

- Cài đặt nginx :

    ```sh
    yum install nginx

    ```

- Khởi động nginx :

    ```sh
    systemctl start nginx
    ```

- Khởi động `firewall-cmd` :

    ```sh
    systemctl start firewalld
    systemctl enable firewalld
    ```

- Cấu hình firewall  và restart lại dịch vụ:

    ```sh
    sudo firewall-cmd --permanent --zone=public --add-service=http 
    sudo firewall-cmd --permanent --zone=public --add-service=https
    sudo firewall-cmd --reload

    ```

- Cài đặt apache :

    ```sh
    yum install httpd httpd-devel -y
    ```

- Dùng trình soạn thảo `vi` để mở file `/etc/httpd/conf/httpd.conf`

    ```sh
    vi /etc/httpd/conf/httpd.conf
    ```

- Tìm và sửa lại các dòng sau :

    ```sh
    Listen 81
    ServerName www.example.com:81
    ```

- Sau đó mở port 81 trên server :

    ```sh
    firewall-cmd --zone=public --add-port=81/tcp
    ```
- Restart lại dịch vụ :

    ```sh
    systemctl restart httpd
    ```

###  3. Cài đặt và cấu hình Keep alive

- Trên cả 2 node load balancing chúng ta thực hiện giống hệt nhau :

- Cài đặt các gói phần mềm hỗ trợ :

    ```sh
    yum install gcc kernel-headers kernel-devel -y
    ```

- Cài đặt keep alive :

    ```sh
    yum install keepalived
    ```

- Dùng trình soạn thảo `vi` mở file `/etc/keepalived/keepalived.conf` :

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
            10.10.20.69
        }
    ```

- Khởi động dịch vụ :

    ``sh
    service keepalived start
    chkconfig keepalived on
    ```

- Kiểm tra lại địa chỉ :

    ```sh
    ip addr show eth1
    ```

- Từ bây giờ chúng ta chỉ cần truy cập vào địa chỉ `10.10.20.69` là có thể truy cập được vào các máy chủ đã được cấu hình, cho dù máy `10.10.20.30` có bị hỏng, down thì máy `10.10.20.40` sẽ làm thay công việc của `10.10.20.30` do đó chúng ta vẫn duy trì được load balancing.