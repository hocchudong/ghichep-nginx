# Cấu hình nginx loadbalancing .

======================================

- [1.  Mô hình](#1)

- [2. Một số giải pháp](#2)
  
  - [2.1. Weight load balancing](#2.1)
  
  - [2.2. Round robin](#2.2)
  
  - [2.3. Least connection](#2.3)
  
  - [2.4. Health check](#2.4)
  
  - [2.5. Kết hợp các thuật toán](#2.5)

======================================
<a name="1"></a>
## 1. Mô hình.

![loadbalancing](/images/loadbalancing.png)
<a name="2"></a>
## 2. Một số giải pháp.

- Cân bằng tải là một kỹ thuật thường dùng để tối ưu hóa việc sử dụng tài nguyên , tối đa hóa thông lượng , giảm độ trễ về đảm bảo tính chịu lỗi.

- Chúng ta có thể sử dụng nginx như là một bộ cân bằng tải để phân phối lưu lượng truy cập đến các máy chủ nhằm mục đích cải thiện hiệu năng , khả năng mở rộng và độ tin cậy của các ứng dụng web với nginx.

- Có rất nhiều thuật toán được xây dựng cho việc cân bằng tải, mỗi thuật toán đều có những ưu nhược điểm khác nhau, trong mỗi trường hợp sẽ có được tác dụng riêng, chúng ta cũng có thể kết hợp các thuật toán với nhau để giúp cho hệ thống của chúng ta hoạt động được tốt hơn. Tùy vào cơ sở hạ tầng và mục đích sử dụng thì chúng ta sẽ lựa chọn thuật toán phù hợp với hệ thống . Sau đây là một số thuật toán cân bằng tải.

<a name="2.1"></a>
### 2.1. Weighted load balancing.

- Đây là một thuật toán quan trọng trong loadbalancing, khi sử dụng thuật toán này sẽ giúp chúng ta giải quyết đươc bài toán phân chia các server xử lý. Vói mặc định của nginx sử dụng thuật toán round-robin thì các request sẽ được chuyển luân phiên đến các server để xử lý, tuy nhiên đối với Weighted load balancing thì chúng ta sẽ phân ra được khối lượng xử lý giữa các server.

- Ví dụ chúng ta có 2 server dùng để load balancing muốn cứ 5 request đến thì 4 dành cho server 1, 1 dành cho server 2 hay các trường hợp tương tự thì weighted load balancing là sự lựa chọn hợp lý.

- Dưới đây là cách cấu hình chi tiết.

#### 2.1.1. Trên các node apache :

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

#### 2.1.2. Trên node nginx.

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
            server 10.10.20.20:80 weight=2;
        }

    # Cấu hình trên có nghĩa là cứ 5 request gửi tới server sẽ có 3 request vào web 1 và 2 request vào web 2.


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

#### 2.1.3. Kiểm tra .

- Truy cập vào địa chỉ nginx web : http://10.10.20.30

- Kết quả :

![loadbalancing1](/images/loadbalancing1.png)

Sau 3 request :

![loadbalancing2](/images/loadbalancing2.png)

<a name="2.2"></a>
### 2.2.  Round Robin.

- Round Robin là thuật toán mặc định của nginx khi chúng ta không có cấu hình gì thêm trong block `http` .

- Đặc ddieeerm của thuật toán này là các request sẽ được luân chuyển liên tục giữa các server 1:1 , điều này sẽ làm giải tải cho các hệ thống có lượng request lớn.

#### 2.2.1. Cấu hình tiết.

- Dùng trình soạn thảo `vi` mở file `/etc/nginx/nginx.conf`

    ```sh
    vi /etc/nginx/nginx.conf
    ``` 

- tại block  `http` sửa lại như sau :

    ```sh
    http {

        upstream backends {
            server 10.10.20.10:80;
            server 10.10.20.20:80;
        }
    ```
<a name="2.3"></a>
### 2.3. Least connection.

- Đây là thuật toán nâng cấp của round robin và weighted load balancing, thuật toán này sẽ giúp tối ưu hóa cân bằng tải cho hệ thống. 

- Đặc điểm của thuật toán này là sẽ chuyển request đến cho server đang xử lý it hơn làm việc, thích hợp đối với các hệ thống mà có các session duy trì trong thời gian dài, tránh được trường hợp các session duy trì quá lâu mà các request được chuyển luân phiên theo quy tắc định sẵn , dễ bị down 1 server nào đó do xr lý qúa khả năng của nó.

#### Cấu hình .

    vi /etc/nginx/nginx.conf

- tại block  `http` sửa lại như sau :

    ```sh
    http {

        upstream backends {
            least_conn;
            server 10.10.20.10:80;
            server 10.10.20.20:80;
        }
    ```
<a name="2.4"></a>
### 2.4. Health check.

- Thuật toán này xác định máy chủ sẵn sàng xử lý request để gửi request đến server , điều này tránh được việc phải loại bỏ thủ công một máy chủ không sẵn sàng xử lý.

- Các hoạt động của thuật toán này là nó sẽ gửi một kết nối TCP đến máy chủ , nếu như máy chủ đó lắng nghe trên địa chỉ và port đã cấu hình thì nó mới gửi request đến cho server xử lý.

- Tuy nhiên health check vẫn có lúc kiể tra xem máy chủ có sẵn sàng hay không, đối với các máy chủ cơ sở dữ liệu thì health check không thể làm điều này.

#### Cấu hình .

      vi /etc/nginx/nginx.conf


- tại block  `http` sửa lại như sau :

    ```sh
    http {

        upstream backends {
            server 10.10.20.10:80;
            server 10.10.20.20:80 max_fails=3 fail_timeout=5s;
            server 10.10.20.10:80;
        }
    ```
<a name="2.5"></a>
### 2.5. Load balancing kết hợp thuật toán.

- Các thuật toán không bao giờ có thể hữu dụng trong tất cả các trường hợp,việc lựa chọn thuật toán dựa trên cơ sở hạ tầng chúng ta có cũng như mục đích sử dụng, để có thể tối ưu hóa hơn trong việc cân bằng tải thông thường chúng ta sẽ kết hợp các thuật toán lại với nhau để có thể đưa ra được giải pháp cân bằng tải hợp lý nhất cho hệ thống. Sau đây là một số giải pháp kết hợp.

####  2.5.1. Kết hợp least  balancing và weight load balancing.

- Thuật toán least load balancing giúp hệ thống có thể lựa chọn server đang xử lý ít hơn để gửi request cho server đó xử lý . Ngoài ra nó còn có thể tự loại bỏ server bị lỗi trong vòng xử lý của nó. Tuy nhiên least load balancing chỉ hữu hiệu khi chúng ta có 2 server có cùng cấu hìn. Giả sử chúng ta có 2 server , server1 có cấu hình mạnh ghấp 2 lần server2 thì chúng ta dùng least load balancing thì đến một thời điểm nào đó con server2 rất dễ bị tèo. Do đó để tránh trường hợp này chúng ta có một giải pháp có thể giảm thiểu khả năng tèo của con thứ 2 đó là kết hợp thêm thuật tóan weighted load balacing :

- Chi tiết cấu hình trong trường hợp  trên như sau :


    ```sh
    http {

        upstream backends {
            least_conn;
            server 10.10.20.10:80 weight=2;
            server 10.10.20.20:80 weight=1;
        }
    ```

- Tham khảo thêm một số giải pháp  tại [đây](https://www.nginx.com/blog/load-balancing-with-nginx-plus-part2/?_ga=1.129223048.568102583.1493302924)