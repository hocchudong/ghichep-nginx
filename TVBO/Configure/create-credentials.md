# Thực hiện cấu hình cho phép client truy cập tới server qua giao thức https.


# Mục lục

- [Tạo chứng chỉ tin cậy cho web server](#create-ca)
- [Thực hiện cấu hình cho server](#configuration)
- [Các nội dung khác](#content-others)


# Nội dung

- ##### <a name="create-ca">Tạo chứng chỉ tin cậy cho web server</a>

	+ Trước hết, bạn hãy đọc nội dung của trang web [Giao thức https hoạt động như thế nào? | inet.vn](https://tintuc.inet.vn/giao-thuc-https-hoat-dong-nhu-nao.html) nếu như muốn biết tại sao cần phải thực hiện điều này trước khi cấu hình cho server sử dụng giao thức https?

	+ Bước đầu tiên để tạo một chứng chỉ tin cậy cho web server, ta cần chạy câu lệnh sau:

			# mkdir /etc/pki/ca-ssl && cd $_
			# openssl genrsa -aes256 -out vhost1.key 2048
			
		Nhập password mà bạn muốn sử dụng cho key đang tạo:

			Generating RSA private key, 2048 bit long modulus
			.........................+++
			............................................................+++
			e is 65537 (0x10001)
			Enter pass phrase for vhost1.key:
			Verifying - Enter pass phrase for vhost1.key:

	+ Xóa passphrase từ private key - cho phép quá trình chứng thực không dùng private key:

			# openssl rsa -in vhost1.key -out vhost1.key

		Nhập password đã nhập ở bước đầu tiên:

			Enter pass phrase for vhost1.key:
			writing RSA key

	+ Tạo chứng nhận yêu cầu đăng nhập:

			#  openssl req -utf8 -new -key vhost1.key -out vhost1.csr

		Bạn sẽ được yêu cầu cung cấp các thông tin để tạo ra một chứng chỉ tin cậy.

	+ Tạo chứng chỉ từ chứng chỉ yêu cầu đăng nhập với hạn 10 năm :laught: và tự ký (tự xác nhận):

			# openssl x509 -in vhost1.csr -out vhost1.crt -req -signkey vhost1.key -days 3650
			Signature ok
			...
			Getting Private key

		Vậy là đã tạo xong chứng chỉ để sử dụng cấu hình cho web server.


- ##### <a name="configuration">Thực hiện cấu hình cho server</a>

	+ Để thực hiện cấu hình cung cấp giao thức https cho *server Block* (vhost1) đã tạo bằng việc thêm nội dung sau vào file cấu hình */etc/nginx/conf.d/vhost1.com.conf*:

			server {
		        ...
		        listen       443 ssl;
				...
		        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
		        ssl_prefer_server_ciphers on;
		        ssl_ciphers ECDHE+RSAGCM:ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:!aNULL!eNull:!EXPORT:!DES:!3DES:!MD5:!DSS;
		        ssl_certificate      /etc/pki/ca-ssl/vhost1.crt;
		        ssl_certificate_key  /etc/pki/ca-ssl/vhost1.key;
       		}

	+ Restart lại nginx:

			# systemctl restart nginx

	+ Thực hiện cấu hình firewall cho phép chạy dịch vụ https sử dụng cổng 443 (default):

			# firewall-cmd --add-service=https --permanent
			# firewall-cmd --reload

		Vậy là đã xong phần cấu hình cung cấp giao thức https cho web server.

- # <a name="content-others">Các nội dung khác</a>

	+ [](#)