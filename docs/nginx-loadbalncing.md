# Cấu hình nginx loadbalancing .

## 1. Mô hình.

![loadbalancing](/images/loadbalancing.png)

## 2. Cài đặt.

### 2.1. Trên các node apache :

- Cài đặt apache :

```sh
yum install httpd httpd-devel
```

- Khởi động apache :

```sh
systemctl start httpd
```

- Truy cập thư mục `/var/www/html`

```sh
cd /var/www/html
```

- Tạo file `index.html`

```sh
vi index.html
```

- Thêm nội dung vào file `index.html` :

```sh
################### WEB 1 (2) #################
```

### 2.2. Trên node nginx.

- - Thêm repo nginx:

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

- Truy cập vào địa chỉ để kiểm tra :

![centos_install](/images/centos_install.png)

- Dùng trình soạn thảo `vi` mở file `/etc/nginx/nginx.conf `

```sh
vi /etc/nginx/nginx.conf 
```

Sửa lại cấu hình như sau :

- Tại block `http` thêm các cấu hình :

```sh
http {

    upstream backends {
        server 10.10.20.10:80 weight=3;
        server 10.10.20.20:80;
    }

# weight=3 có nghĩa là cứ 3 request gửi vào web 1 thì có 1 request gửi vào web 2.


```

- Tại block server thêm hoặc sửa các cấu hình thành như sau :

```sh
    server {

        listen      80 default_server;
        listen      [::]:80 default_server;
        server_name _;

        proxy_redirect           off;
        proxy_set_header         X-Real-IP $remote_addr;
        proxy_set_header         X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header         Host $http_host;

        location / {
            proxy_pass http://backends;
        }


```

- Restart lại nginx :

```sh
systemctl restart nginx 
```

### 3. Kiểm tra .

- Truy cập vào địa chỉ nginx web : http://10.10.20.30

- Kết quả :

![loadbalancing1](/images/loadbalancing1.png)

Sau 3 request :

![loadbalancing2](/images/loadbalancing2.png)