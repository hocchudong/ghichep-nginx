# Thiết lập virtual host trên nginx.



- Dùng lệnh sau để tạo 1 cây thư mục mới dành cho website :

    ```sh
    mkdir -p /var/www/datpt.com/{public_html,logs,backup}
    ```

- Phân quyền cho thư mục vừa mới tạo :

    ```sh
    chown -R nginx:nginx /var/www
    ```

- Dùng trình soạn thảo vi để tạo ra file `datpt.com.conf`

    ```sh
    vi /etc/nginx/conf.d/datpt.com.conf
    ```

- Thêm nội dung sau vào file vừa tạo :

    ```sh
    server {
    listen  80;
    server_name datpt.com www.datpt.com;
    access_log /var/www/datpt.com/logs/access.log;
    error_log /var/www/datpt.com/logs/error.log main;
    root /var/www/datpt.com/public_html;
    index.html index.htm index.php;
    }
    ```

- Dùng trình soạn thảo vi sửa lại file `/etc/nginx/nginx.conf`

    ```sh
    vi /etc/nginx/nginx.conf
    ```

- Sửa lại các thông số sau :

    ```sh
    # Tìm đến dòng server_name sửa lại thành :
    server_name datpt.com   www.datpt.com;

    # tìm đến dòng root , sửa lại thành :
    root    /var/www/datpt.com/public_html;
    ```

- Dùng trình soạn thảo `vi` sửa lại file hosts :

    ```sh
    vi /etc/hosts
    ```

- Thêm vào file hosts dòng sau :

    ```sh
    # 10.10.20.30 là địa chỉ website của chúng ta
    10.10.20.30 www.datpt.com
    ```

- Dùng trình soạn thảo `vi` tạo file `index.html` trong thư mục chứa website :

    ```sh
    vi /var/www/datpt/public_html/index.html
    ```

- Thêm vào file `index.html` nội dung mà chúng ta muốn hiển thị :

    ```sh
    @@@@@@@@@@@@@@@@@@@@@@@@@ Xin Chao @@@@@@@@@@@@@@@@@ 
    ```

- Kiểm tra lại các cấu hình : 

![virtualhost](/images/virtualhost.png)
