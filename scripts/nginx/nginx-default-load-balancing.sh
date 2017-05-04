################### Nginx Load Balancing #######################

source config.cfg
source function.sh

echocolor "Install Nginx"

sleep 3

yum -y install epel-release
yum -y install nginx
systemctl start nginx

echocolor "Setup Firewall"

sleep 3

systemctl start firewalld
systemctl enable firewalld

sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

echocolor "Config Nginx"

sleep 3

filenginx=/etc/nginx/nginx.conf
rm $filenginx
touch $filenginx

cat <<EOF>> $filenginx
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

    include /etc/nginx/conf.d/*.conf;

    upstream backends {
        server $DEFAULT_1:80;
        server $DEFAULT_2:80;
    }

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
            proxy_pass proxy_pass http://backends;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }



}
EOF

echocolor "Restart nginx"

sleep 3

systemctl restart nginx

