#!/usr/local/bin/bash
sysrc mysql_enable="YES"
sysrc mysql_pidfile=/var/db/mysql/mysql.pid

mkdir /var/log/mysql
chown mysql /var/log/mysql

CFG_FILE="/usr/local/etc/mysql/my.cnf"

mv ${CFG_FILE} ${CFG_FILE}.BU
mv ${CFG_FILE}.template ${CFG_FILE}

echo "Start MariaDB server"
service mysql-server start

# change password
echo "Change MariaDB root password"

USER="root"
PASS=$(cat /dev/urandom | strings | tr -dc 'a-zA-Z0-9' | fold -w 40 | head -n 1)
echo $PASS > /root/mysqlrootpassword
mysqladmin --user=$USER password "$PASS"

# configure MariaDB
echo "Configure MariaDB"

mysql -u $USER -p"${PASS}" << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${PASS}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
