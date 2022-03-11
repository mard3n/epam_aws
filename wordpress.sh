#!/bin/bash

yum update -y
yum install httpd amazon-efs-utils mysql -y

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /var/www/html
echo '${efs_dns_name}:/ /var/www/html nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab


myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body>
<p>$myip</p>
</body>
</html>
EOF

service httpd start

sudo amazon-linux-extras install epel
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum-config-manager --enable remi-php72
sudo yum -y update
sudo amazon-linux-extras install php7.2 -y

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-backup.conf
sed -i '151s/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

cd /var/www/html/
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
mysql -u ${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} -e "create database ${DB_NAME}";
wp core download
wp core config --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD} --dbhost=${DB_HOST}
wp core install --url="${elb_dns_name}" --title="${WP_TITLE}" --admin_user=${WP_USER} --admin_password=${WP_PASS} --admin_email=${WP_EMAIL}
chmod -R 755 wp-content
chown -R apache:apache wp-content
cat <<EOF >> /var/www/html/wp-config.php
define('WP_HOME', '/');
define('WP_SITEURL', '/');
EOF
cat <<EOF > /var/www/html/.htaccess
Options +FollowSymlinks
RewriteEngine on
rewriterule ^wp-content/uploads/(.*)$ http://${elb_dns_name}/wp-content/uploads/\$1 [r=301,nc]
EOF

rm index.html

service httpd restart
chkconfig httpd on

