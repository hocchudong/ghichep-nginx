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