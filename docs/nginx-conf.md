# Cấu hình nginx .

=============================================

## Mục lục.

- [I. giới thiệu về file cấu hình](#i)

- [II. Giải thích file cấu hình](#ii)

  - [1. Main block](#1)
  
  - [2. Event block](#2)
  
  - [3. HTTP block](#3)

=============================================
<a name="i"></a>
## I. Giới thiệu về file cấu hình.

- Mặc định nginx có đường dẫn `/etc/nginx/nginx.conf`.

- Nginx quản lý cấu hình theo `Derective` và `Block` chúng có thể nằm lồng ghép với nhau. Những derective không thuộc block nào sẽ nhóm lại gọi là `Main Block` những cấu hình trên Block này sẽ ảnh hường tới toàn bộ server.

- Nếu một derective nằm trong block nào đó thì nó có ý nghĩa trong block đó và các block con bên trong , khi derective được định nghĩa lại trong các block con thì nó chỉ có tác dụng trong block con đó. 


- File cấu hình :

    ```sh
    # For more information on configuration, see:
    #   * Official English Documentation: http://nginx.org/en/docs/
    #   * Official Russian Documentation: http://nginx.org/ru/docs/

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
            }

            error_page 500 502 503 504 /50x.html;
                location = /50x.html {
            }
        }

    # Settings for a TLS enabled server.
    #
    #    server {
    #        listen       443 ssl http2 default_server;
    #        listen       [::]:443 ssl http2 default_server;
    #        server_name  _;
    #        root         /usr/share/nginx/html;
    #
    #        ssl_certificate "/etc/pki/nginx/server.crt";
    #        ssl_certificate_key "/etc/pki/nginx/private/server.key";
    #        ssl_session_cache shared:SSL:1m;
    #        ssl_session_timeout  10m;
    #        ssl_ciphers HIGH:!aNULL:!MD5;
    #        ssl_prefer_server_ciphers on;
    #
    #        # Load configuration files for the default server block.
    #        include /etc/nginx/default.d/*.conf;
    #
    #        location / {
    #        }
    #
    #        error_page 404 /404.html;
    #            location = /40x.html {
    #        }
    #
    #        error_page 500 502 503 504 /50x.html;
    #            location = /50x.html {
    #        }
    #    }

    }


    ```
<a name="ii"></a>
## II. Giải thích file cấu hình.
<a name="1"></a>
### 1. MAIN BLOCK .

- `User nginx;` : Cấu hình quy định worker processes được chạy với tài khoản nào , ở đây là nginx.

- `worker_processes auto;` : Cấu hình chỉ ra rằng web server được xử lý bằng 1 CPU core (processor) , giá trị này tương ứng với số CPU Core có trên máy chủ. Để kiểm tra số lượng CPU Core trên máy chủ chúng ta dùng lệnh :

    ```sh
    nproc

    # hoặc 

    cat /proc/cpuinfo
    ```

- `error_log /var/log/nginx/error.log;` Đường dẫn đến file log của nginx.

- `pid /run/nginx.pid;` số PID của master process , nginx sử dụng master process để quản lý worker process.
<a name="2"></a>
### 2. Event Block .

- `worker_connections 1024;` Giá trị này liên quan đến worker processes, 1024 có nghĩa là mỗi worker process sẽ chịu tải là 1024 kết nối cùng lúc . Nếu chúng ta có 2 worker process thì khả năng chịu tải của server là 2048 kết nối tại một thời điểm. Giá trị này chúng ta có thể tùy thuộc vào phần cứng của máy chủ (giá trị 1024/worker process không phải là mặc định).
<a name="3"></a>
### 3. HTTP Block .

- log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    ```sh
    Định nghĩa một mẫu log có tên là main được sử dụng bởi access_log , các thông tin được đưa vào file tương ứng với các 
    biến như $remote_addr, $remote_user ,....
    ```

- access_log  /var/log/nginx/access.log  main;

    ```sh
    Chỉ ra đường dẫn tới file log .
    ```

- `sendfile on;` Cấu hình này gọi đến function sendfile để xử lý việc truyền file .

- `tcp_nopush on;` 

- `tcp_nodelay on;`

- `keepalive_timeout   65;` Xác định thời gian chờ trước khi đóng 1 kết nối, ở đây là 65s.

-  include /etc/nginx/mime.types;
   default_type        application/octet-stream;

    ```sh
    Gọi tới file chứa danh sách các file extension trong nginx
    ```

- `types_hash_max_size 2048;`

