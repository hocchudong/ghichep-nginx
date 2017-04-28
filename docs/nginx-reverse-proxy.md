# Cấu hình Nginx làm reverse proxy cho apache .

====================================================

# Mục lục.

- [Mục đích](#md)

- [Mô hình](#mh)

- [Cài đặt chi tiết](#cd)

====================================================
<a name="md"></a>
## Mục đích :

- Apache là một `Open Source Webserver` phổ biến nhất hiện nay bởi vì có rất nhiều software tuyệt vời hỗ trợ như: cPanel, DirectAdmin,... Điều mà Nginx chưa có. 

- Tuy nhiên có một nhược điểm của Apache đó là nó kém linh hoạt, xử lý khá chậm và chiếm rất nhiều bộ nhớ mỗi khi cần xử lý dữ liệu, dù dữ liệu đó là tính hay động. 

- Còn với nginx luôn có khả năng xử lý nhanh hơn apache , linh hoạt hơn và nhẹ hơn apache rất nhiều. Cách cấu hình nginx theo đánh giá của nhiều người thì là gọn gàng và đơn giản hơn.

- Nginx rất đa nhiệm do đó để tối ưu hóa hơn cho webserver người ta thường sử dụng song hành Nginx và Apache . Việc sử dụng song hành như thế không gây ảnh hưởng gì , thậm chí còn tiết kiệm được nhiều tài nguyên hơn ,website tải nhanh hơn. Kỹ thuật đơn giản nhất để song hành nginx và apache là làm proxy trung gian để gửi dữ liệu đã xử lý thông tin qua apache đến trình duyệt người dùng.  Ở đây chúng ta sẽ xử lý các thông tin về PHP, Python ,... qua module của apache còn nginx sẽ đọc dữ liệu nhận được , xử lý các file tĩnh , cache (nginx sẽ làm tốt hơn trong việc xử lý cache).
<a name="mh"></a>
## Mô hình.

![proxy_reverse](/images/proxy_reverse.png)
<a name="cd"></a>
## Cài đặt chi tiết .

### 1. Trên node nginx .

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

- Truy cập vào địa chỉ để kiểm tra :

![centos_install](/images/centos_install.png)

- Dùng trình soạn thảo `vi` mở file cấu hình `/etc/nginx/nginx.conf `

    ```sh
    vi /etc/nginx/nginx.conf 
    ```

- Tại block server sửa lại thông số như sau :

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
                proxy_pass http://10.10.20.10/;
            }

        }

    # trong đó 10.10.20.10 là địa chỉ của apache
    ```

- Restart lại nginx :

    ```sh
    systemctl restart nginx 
    ```

### 2. Cài đặt trên node apache .

- Cài đặt apache :

    ```sh
    yum install httpd httpd-devel -y
    ```

- Dùng trình soạn thảo `vi` mở file `/etc/httpd/conf/httpd.conf`

    ```sh
    vi /etc/httpd/conf/httpd.conf 
    ```

- Tìm đến dòng 196 và sửa lại thành :

    ```sh
    LogFormat "\"%{X-Forwarded-For}i\" %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined 
    ```

- Restart lại apache :

    ```sh
    systemctl restart httpd 
    ```

### 3. Kiểm tra .

- Truy cập vào địa chỉ nginx :

http://10.10.20.30

Kết quả nhận được :

![proxy](/images/proxy.png)
