# Cài đặt Nginx.

==============================================

## Mục Lục.

- [1. Tổng quan về nginx](#1)

- [2. Cài đặt](#2)

==============================================

<a name="1"></a>
## 1. Tổng quan về Nginx.

- Nginx là sản phẩm mã nguồn mở dành cho web server . Là một reverse proxy cho các giao thức HTTP, SMTP , POP3 và IMAP. Nhằm nâng cao hiệu suất xử lý khi sử dụng lượng RAM thấp . Được cấp phép bởi BSD chạy trên nền tảng UNIX, Linux và các biến thể BSD , Mac OS , Solaris, AIX, HP-UX và windows.

- Nginx có thể triển khai nội dung của các trang web động bằng cách sử lý FastCGI, SCGI  cho các scripts . Và có thể sử dụng như là một server cân bằng tải . Sau đó vấn đề C10K xuất hiện  nói cách khác để cho phép mỗi máy chủ web phải có khả năng xử lý 10.000 khách hàng cùng một lúc.  Cần phải phát triển một mạng lưới  I / O tốt hơn và công nghệ quản lý chủ đề đã được xuất hiện. Sự xuất hiện của NGinx không phải là kết quả của một nỗ lực để giải quyết vấn đề C10K (như là một vấn đề phổ biến) nhưng “vấn đề C10K” đã thành công trong việc đưa ra các  nỗ lực để nâng cao hiệu suất phát triển mạng máy chủ

- Igor Sysoev phát triển nginx từ cách đây hơn 9 năm. Vào tháng 10/2004, phiên bản 0.1.0 được phát hành rộng rãi theo giấy phép BSD. Công dụng của nginx ngoài máy chủ web, còn có thể làm proxy nghịch cho Web và làm proxy email (SMTP/POP3/IMAP). Theo thống kê của Netcraft, trong số 1 triệu website lớn nhất thế giới, có 6,52% sử dụng nginx. Tại Nga, quê hương của nginx, có đến 46,9% sử dụng máy chủ này. Nginx chỉ đứng sau Apache và IIS (của Microsoft).

- Nginx cung cấp gần như tất cả các chức năng máy chủ web:
<a name="2"></a>
## 2. Cài đặt.

- 

- Thêm nginx repository bằng việc tạo một file */etc/yum.repos.d/nginx.repo* bằng câu lệnh sau:

      sudo vi /etc/yum.repos.d/nginx.repo

  sau đó thêm nội dung này vào file:

      [nginx]
      name=nginx repo
      baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
      gpgcheck=0
      enabled=1

- Update lại hệ thống:

       sudo yum update

- Cài đặt nginx sử dụng câu lệnh:

      sudo yum install nginx

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

- Cấu hình để nginx tự khởi động sau mỗi lần restart server bằng việc sử dụng câu lệnh:

        # systemctl enable nginx