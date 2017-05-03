# HƯỚNG DẪN SỬ DỤNG SCRIPTS NGINX LOAD BALANCING.

## I. Cài đặt Nginx.

- tải script :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```

- Cài đặt Nginx :

    ```sh
    bash install.sh
    ```

## II. Cài đặt Nginx Reverse Proxy.

### 1. Trên node nginx.

- Tải Scripts :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```


- Mở file `config.cfg` sau đó chỉnh sửa lại cấu hình :

    ```sh
    IP_REVERSE_PROXY=10.10.20.20

    # Chỉnh sửa thành địa chỉ IP tương ứng với node của chúng ta thiết lập.
    ```

- Chạy script :

    ```sh
    bash nginx-revrse-proxy.sh
    ```

### 2. Trên node apache.

- Tải script :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```

- Chạy script :

    ```sh
    bash apache.sh
    ```

## III. Cài đặt nginx load balacing.

### 1. Sử dụng thuật toán mặc định Round Robin.

- Tải script :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```

- Mở file `config.cfg` và sửa lại các cấu hình :

    ```sh
    DEFAULT_1=10.10.20.10
    DEFAULT_2=10.10.20.30

    # Sửa thành ip các node load balancing tương ứng.
    ```

- Chạy script :

    ```sh
    bash nginx-default-loadbalancing.sh
    ```

### 2. Sử dụng thuật toán weight load balancing .

- Tải script :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```

- Mở file `config.cfg` và sửa lại các cấu hình :

    ```sh
    WEIGHT_1=10.10.20.10
    WEIGHT_2=10.10.20.30
    WEIGHT_CONNECTION_1=3
    WEIGHT_CONNECTION_2=1

    # Sửa thành ip các node load balancing tương ứng và các connection tùy chọn cho các node mà mong muốn.
    ```

- Chạy script :

    ```sh
    bash nginx-weight-load-balancing.sh
    ```

### 3. Sử dụng thuật toán least load balancing.

- Tải script :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```

- Mở file `config.cfg` và sửa lại các cấu hình :

    ```sh
    DEFAULT_1=10.10.20.10
    DEFAULT_2=10.10.20.30

    # Sửa thành ip các node load balancing tương ứng.
    ```

- Chạy script :

    ```sh
    bash nginx-least-load-balancing.sh
    ```

### 4. Sử dụng thuật toán health check.

- Tải script :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```

- Mở file `config.cfg` và sửa lại các cấu hình :

    ```sh
    HEALTH_CHECK_1=10.10.20.10
    HEALTH_CHECK_2=10.10.20.30
    MAX_FAILS=3
    FAIL_TIMEOUT=5s

    # Chỉnh sửa những thông số phù hợp với yêu cầu của hệ thống.
    ```

- Chạy script :

    ```sh
    bash nginx-healthcheck-load-balancing.sh
    ```

### 5. Sử dụng kết hợp thuật toán load balancing.

- Tải script :

    ```sh
    yum -y update && yum -y install git
    git clone git clone https://github.com/hocchudong/ghichep-nginx.git
    cd ghichep-nginx/scripts/nginx/
    chmod +x *.sh
    ```

- Mở file `config.cfg` và sửa lại các cấu hình :

    ```sh
    PLUS_1=10.10.20.10
    PLUS_2=10.10.20.30
    PLUS_1_CONNECTION=3
    PLUS_2_CONNECTION=1

    # Chỉnh sửa những thông số phù hợp với yêu cầu của hệ thống.
    ```

- Chạy script :

    ```sh
    bash nginx-loadbalancing-plus.sh
    ```
