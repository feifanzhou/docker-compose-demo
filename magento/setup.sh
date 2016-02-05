mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS magento"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL ON magento.* TO 'magento'@'%' IDENTIFIED BY 'magento'"
install-magento
