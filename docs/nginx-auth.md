# Xác thực để vào page .

- Cài đặt gói `httpd-tools`

    ```sh
    yum -y install httpd-tools 
    ```

- Dùng trình soạn thảo `vi` để mở file `/etc/nginx/nginx.conf`

    ```sh
    vi /etc/nginx/nginx.conf 
    ```

- Thêm vài Block server các thông số sau :

    ```sh
            location /auth {
                auth_basic            "Basic Auth";
                auth_basic_user_file  "/etc/nginx/.htpasswd";
            }

    # Trong đó /auth là folder mà chúng ta sẽ sử dụng để khi client truy cập vào folder đó cần phải xác thực mới xem được.
    ```

- Tạo tài khoản và mật khẩu để xác thực :

    ```sh
    htpasswd -c /etc/nginx/.htpasswd cent

    New password:     # set password

    Re-type new password:
    Adding password for user cent

    # cent là tài khoản chúng ta tạo để xác thực.
    ```

- Restart lại nginx :

    ```sh
    systemctl restart nginx 
    ```

- Tại `Doucument Root` tạo ra thư mục `auth` và file `index.html` :

    ```sh
    mkdir auth
    cd auth
    vi index.html
    ```

- Thêm nội dung vào file `index.html`

    ```sh
    #################### test #################### 
    ```

## Kiểm tra :

- Truy cập vào địa chỉ chúng ta cấu hình xác thực :

![auth](/images/auth.png)

- Nhập tài khoản và mật khẩu vừa thiết lập  :

![okauth](/images/okauth.png)
