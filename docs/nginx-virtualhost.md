# Cách tạo virtual host (Server Block)


# Mục lục

- [Virtual Host là gì?](#virtual-host)
- [Cách tạo và cấu hình cho một Virtual Host](#configure)
- [Các nội dung khác](#content-others)


# Nội dung

- ##### <a name="virtual-host">Virtual Host là gì?</a>
    
    + *Virtual Host* là một kỹ thuật cho phép nhiều website có thể dùng chung một địa chỉ ip duy nhất. Thuật ngữ này được sử dụng với các website sử dụng Apache server. Trong các website sử dụng Nginx server thì nó được gọi là các *Server Block* sử dụng khai báo qua *server_name* trong file cấu hình và có thể lắng nghe các chỉ thị để liên kết với tcp sockets.
    + Đây là kỹ thuật dùng để cấu hình cho web server khi bạn muốn có nhiều tên miền được sử dụng chung trên cùng một máy chủ.
        ![virtual host](../images/virhost.png)


- ##### <a name="configure">Cách tạo và cấu hình cho một Virtual Host</a>

    + Để thiết lập được một *Server Block* trong nginx. Ta cần phải trải qua các bước sau:
        
        * Bước 1: Tạo một file cấu hình cho *Block Server* mới.
        * Bước 2: Tạo một cây thư mục chứa nội dung website cho *Server Block* mới.
        * Bước 3: Thêm nội dung của trang web để kiểm tra cấu hình
    Đó là 3 bước cơ bản để tạo ra một *Server Block* mới trong nginx để chia sẻ địa chỉ ip cho nhiều website cùng sử dụng. Dưới đây sẽ là chi tiết về nội dung của 3 bước trên.



    + Bước 1: Tạo một file cấu hình cho *Block Server* mới.

        - Trong thư mục cấu hình của nginx đã phân chia khá rõ ràng về tác dụng của các thư mục. Ta có */etc/nginx/nginx.conf* chính là file cấu hình chính cho nginx, */etc/nginx/conf.d/* là thư mục chứa các file cấu hình khác cho server, thông thường thì đây là thư mục được sử dụng để chứa các file cấu hình cho *Server Block*. Để tạo file cấu hình mới cho *Server Block* ta sử dụng câu lệnh sau:

                # vi /etc/nginx/conf.d/vhost1.com.conf

        - Tiếp theo ta cần thêm nội dung cấu hình cho file vừa tạo trên với nội dung:

                server {
                    listen      80;
                    server_name     vhost1.com www.vhost1.com;
                    access_log      /var/log/nginx/access-vhost1.com.log;
                    error_log       /var/log/nginx/error-vhost1.com.log;
                    root    /usr/share/nginx/vhost1.com;
                    index   index.php index.html index.htm;
                }
        Sau đó hãy lưu file này lại. Trên nội dung cấu hình trên, *vhost1.com* và *www.vhost1.com* là 2 domain ảo được tạo ra dùng cho server.
        
        - Cấu hình trỏ host tới *Server Block* mà ta vừa tạo ra bằng việc thêm nội dung sau vào file *C:\Windows\System32\drivers\etc/hosts* trên client theo dạng:

                ip-address      server_name

        Ví dụ:

                192.168.19.35       vhost1.com www.vhost1.com
    
    + Bước 2: Tạo một cây thư mục chứa nội dung website cho *Server Block* mới.

        - Ta cần tạo mới một cây thư mục để lưu trữ nội dung cho website có server_name mới này bằng việc sử dụng câu lệnh sau:

                # mkdir /usr/share/nginx/vhost1.com
                # chown nginx:nginx -R /usr/share/nginx/vhost1.com
        
        - Ta cần chạy câu lệnh *chown nginx:nginx -R /usr/share/nginx/vhost1.com* để cho phép nginx có thể truy cập và sử dụng tài nguyên ở đó. Lưu ý là: cây thư mục vừa tạo cần phải giống với giá trị trong dòng *root* ở file cấu hình trong Bước 1.

    + Bước 3: Thêm nội dung của trang web để kiểm tra cấu hình

        - Để kiểm tra cấu hình đã chính xác hay chưa, ta nên tạo thêm một file *index.html* trong thư mục vừa tạo ở bước 2 để kiểm tra. Ta sử dụng câu lệnh:

                vi  /usr/share/nginx/vhost1.com/index.html

        - Sau đó thêm nội dung đơn giản giống như sau vào file *index.html*:
                
                <DOCTYPE html>
                <html>
                  <head>
                    <title>www.vhost1.com</title>
                  </head>
                  <body>
                    <h1>Success: You Have Set Up a Virtual Host</h1>
                  </body>
                </html>

        - Khởi động lại nginx server bằng câu lệnh:

                systemctl restart nginx

        - Trên client, mở trình duyệt và truy cập vào domain đã tạo ở trên (ở đây là vhost1.com) để kiểm tra kết quả. Nếu thành công sẽ nhìn thấy nội dung tương tự như sau:

            ![Server Block](../images/sb.png)

            Theo các bước làm trên, ta đã tiến hành thành công tạo một virtual host cho web server của mình.