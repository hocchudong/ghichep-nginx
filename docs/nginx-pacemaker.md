# Ghi chép về pacemaker, corosync.

====================================================

# Mục Lục.

- [I. Một số khái niệm.](#1)

    - [1. Cluster là gì.](#1.1)

    - [2. Resource agents.](#1.2)

    - [3. Corosync.](#1.3)

- [II. Kiến trúc pacemaker.](#2)

- [III. Lab triển khai cluster cho nginx sử dụng pacemaker.](#3)


====================================================

<a name="1"></a>
## I . Một số khái niệm .
<a name="1.1"></a>
### 1. Cluster là gì.

- Cluster là một kiến trúc nhằm đảm bảo nâng cao khả năng sẵn sàng cho các hệ thống mạng máy tính.

- Clustering cho phép sử dụng nhiều máy chủ kết hợp với nhau tạo thành một cụm có khả năng chịu đựng hay chấp 
nhận sai sót (fault-tolerant) nhằm nâng cao độ sẵn sàng của hệ thống mạng.
<a name="1.2"></a>
### 2. Resource agents.

- Pacemaker là một phần của cluster, có trách nhiệm quản lý các tài nguyên.

- Để quản lý tài nguyên, Resource agent được sử dụng.

- Một resource agent là một script mà cluster sử dụng để start, stop và monitor resource. Nó có thể so sánh với 
systemctl hoặc 1 script chạy có mức độ. Nhưng nó được điều chỉnh để sử dụng trong cluster. Nó cũng định nghĩa các 
thuộc tính có thể quản lý bởi cluster. Đối với 1 admin, Nó rất quan trọng để biết được thuộc tính nào có thể sử dụng 
trước khi bắt đầu cấu hình resources.
<a name="1.3"></a>
### 3. Corosync.

- Corosync là một layer có nhiệm vụ quản lý các node thành viên.

- Nó cũng được cấu hình để giao tiếp với pacemaker.

- Pacemaker nhận update về những sự thay đổi trạng thái của các node trong cluster. Dựa vào đó nó có thể bắt đầu một sự 
kiện nào đó ví dụ như migrate resource.
<a name="2"></a>
## II. Kiến trúc pacemaker .

![pacemaker-architect](/images/pacemaker-architect.png)

### 1. Cluster Information Base (CIB).

- Trái tim của cluster là Cluster Information Base (CIB). Đây là trạng thái thực tế trong bộ nhớ của cluster đó là liên tục đông 
bộ giữa các node trong cluster. Đó là một điều rất quan trọng để một admin cần phải biết, Bạn sẽ không bao giờ chỉnh sửa trực tiếp được CIB.

- Các CIB sử dụng XML để đại diện cho cả hai cấu hình của cluster và trạng thái hiện tại của tất cả các resource trong cluster. Nội dung của 
CIB được tự động giữ đồng bộ trên toàn bộ cụm.

### 2. CRMD.

- Cluster Resource Management Daemon là một tiến trình quản lý trạng thái hoạt động của cluster.

- Nhiệm vụ chính của crmd là chuyển tiếp trực tiếp các thông tin giữa nhiều components của cluster. Như việc đặt resource trên các node đặc biệt. Nó cũng 
có trách nhiện quản lý node transition. Node là master crmd thực sự hoạt động được công nhận là designated coordinator (DC). Nếu DC fail, cluster sẽ tự động 
chọn một DC mới rất nhanh chóng.

### 3. PEngine.

- Là một phần của cluster nó tính toán để đạt được.

- Nó tạo ra một danh sách các hướng dẫn được gửi tới crmd. Cách tốt nhất để 1 admin tác động tới hành vi của pengine là đinh nghĩa những hạn chế trong cluster.

### 4. LRMD.

- Local resource management daemon là một phần của cluster được chạy trên mỗi node của cluster.

- Nếu crmd quyết định chạy resource trên node đặc biệt nào, nó sẽ hướng dẫn lrmd vào nút đó để bắt đầu resource.

- Trong trường hợp nó không hoạt động lrmd sẽ trở về crmd và thông báo rằng start resource fail. Sau đó Cluster có thể cố gắng thử lại resource trên nút khác trong cluster.

- LRM cũng có trách nhiệm monitor operation và stop operation mà đang chạy trên node.
<a name="3"></a>
## III. Lab triển khai cluster cho nginx sử dụng pacemaker.

### 1. Mô hình triển khai và phân hoạch IP.

- Mô hình triển khai :

![pacemaker](/images/galera.png)

- Phân hoạch địa chỉ IP :

![ip-pacemaker](/images/ip-pacemaker.png)

### 2. Cài đặt và cấu hình.

#### Cài đặt nginx trên cả 3 node LB.

- Khaibáo repos để tăng tốc độ cài đặt.

    ```sh
    echo "proxy=http://123.30.178.220:3142" >> /etc/yum.conf 
    yum -y update
    ```

- Cài nginx.

    ```sh
    yum install -y wget 
    yum install -y epel-release

    yum --enablerepo=epel -y install nginx
    ```

- Khởi động nginx :

    ```sh
    systemctl start nginx 
    systemctl enable nginx
    ```

#### Cài đặt pacemaker và corosync để tạo cluster cho nginx.

- Chúng ta chỉ cài trên 2 node LB1 và LB2, còn LB3 dùng để mở rộng về sau.

- Cài đặt pacemaker trên LB1 và LB2 :

    ```sh
    yum -y install pacemaker pcs
    ```

- Trên CentOS 7 thì pacemaker và corosync sẽ được cài đựt cùng nhau.

- Khởi động pacemaker :

    ```sh
    systemctl start pcsd 
    systemctl enable pcsd
    ```

- Kiểm tra trạng thái của pacemaker :

    ```sh
    systemctl startus pcsd
    ```

- Kết quả :

    ```sh
        ● pcsd.service - PCS GUI and remote configuration interface
        Loaded: loaded (/usr/lib/systemd/system/pcsd.service; enabled; vendor preset: disabled)
        Active: active (running) since Sat 2017-05-13 20:45:20 +07; 14s ago
        Main PID: 2578 (pcsd)
        CGroup: /system.slice/pcsd.service
                └─2578 /usr/bin/ruby /usr/lib/pcsd/pcsd > /dev/null &

        May 13 20:45:24 lb1 systemd[1]: Starting PCS GUI and remote configuration interface...
        May 13 22:45:25 lb1 systemd[1]: Started PCS GUI and remote configuration interface.
    ```

- Đặt mật khẩu cho hacluster :

    ```sh
    passwd hacluster
    # mật khẩu đặt giống nhau trên cả 2 cluster.
    ```

- Trên 1 trong 2 node chúng ta thực hiện tạo cluster :

    ```sh
    pcs cluster auth lb1 lb2
    ```

Kết quả :

    ```sh
    lb1: Authorized
    lb2: Authorized
    ```

- Cấu hình cho cluster :

    ```sh
    pcs cluster setup --name ha_cluster lb1 lb2
    # ha_cluster là tên của cluster mà bạn sẽ tạo, mục này có thể nhập tùy ý.
    # lb1 lb2 là hostname các máy chủ trong cụm cluster. Muốn sử dụng tên này thì 
    # bạn phải chắc chắn đã khai báo trong file /etc/hosts
    ```

Kết quả :

    ```sh
    Destroying cluster on nodes: lb1, lb2...
    lb1: Stopping Cluster (pacemaker)...
    lb2: Stopping Cluster (pacemaker)...
    lb1: Successfully destroyed cluster
    lb2: Successfully destroyed cluster

    Sending cluster config files to the nodes...
    lb1: Succeeded
    lb2: Succeeded

    Synchronizing pcsd certificates on nodes lb1, lb2...
    lb1: Success
    lb2: Success

    Restarting pcsd on the nodes in order to reload the certificates...
    lb1: Success
    lb2: Success
    ```

- Khởi động cluster vừa tạo :

    ```sh
    pcs cluster start --all 
    ```

- Kích hoạt khởi động cùng OS cho cluster :

    ```sh
    pcs cluster enable --all 
    ```

#### Cấu hình để thêm các resources vào Cluster.

Đứng trên node bất kỳ .

- Disable cơ chế STONITH :

    ```sh
    pcs property set stonith-enabled=false
    ```

- Disable auto failbask :

    ```sh
    pcs property set default-resource-stickiness="INFINITY"
    ```

- Thêm resource Virtual IP (VIP) để pacemaker quản lý :

    ```sh
    pcs resource create Virtual_IP ocf:heartbeat:IPaddr2 ip=10.10.20.69 cidr_netmask=32 op monitor interval=30s
    ```

- Trên 2 node LB cấu hình nginx.conf như sau :

    ```sh
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log;
    pid /run/nginx.pid;

    # Load dynamic modules. See /usr/share/nginx/README.dynamic.
    include /usr/share/nginx/modules/*.conf;

    events {
        worker_connections 1024;
    }

        http {
            upstream backends {
                server 10.10.20.10:80 ;
                server 10.10.20.20:80 ;
            }

        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log  /var/log/nginx/access.log  main;

        sendfile            on;
        tcp_nopush          on;
        tcp_nodelay         on;
        keepalive_timeout   65;
        types_hash_max_size 2048;

        include             /etc/nginx/mime.types;
        default_type        application/octet-stream;

        # Load modular configuration files from the /etc/nginx/conf.d directory.
        # See http://nginx.org/en/docs/ngx_core_module.html#include
        # for more information.
        include /etc/nginx/conf.d/*.conf;

        server {
            listen       80 default_server;
            listen       [::]:80 default_server;
            server_name  lb1;
            
            proxy_redirect           off;
            proxy_set_header         X-Real-IP $remote_addr;
            proxy_set_header         X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header         Host $http_host;

            location / {
                proxy_pass http://backends;
            }
        
        

            # Load configuration files for the default server block.
            include /etc/nginx/default.d/*.conf;

            error_page 404 /404.html;
                location = /40x.html {
            }

            error_page 500 502 503 504 /50x.html;
                location = /50x.html {
            }
        }
    }
    ```

- Thêm resource NGINX để pacemaker quản lý :

    ```sh
    pcs resource create Web_Cluster \
    ocf:heartbeat:nginx \
    configfile=/etc/nginx/nginx.conf \
    status10url \
    op monitor interval=5s 
    ```

#### Cấu hình điều kiện ràng buộc cho các resource :

- Cấu hình để thiết lập resource Virtual_IP và Web_Cluster hoạt động trên cùng 1 máy trong cụm cluster :

    ```sh
    pcs constraint colocation add Web_Cluster with Virtual_IP INFINITY
    ```

- Thiết lập chế độ khởi động của các resource :

    ```sh
    pcs constraint order Virtual_IP then Web_Cluster
    ```

# Tham Khảo :

- https://github.com/congto/openstack-HA/blob/master/caidat-OPS-HA/ghichep-pacemaker_corosync_nginx.md

- https://github.com/greatbn/Pacemaker#2-m%C3%B4-h%C3%ACnh-tri%E1%BB%83n-khai