export DOMAIN=142.150.208.206;
export LOCAL_IP=$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}');

# Set password as Heat parameter
export PASSWORD="ABC123"

echo "Update packages lists...";
sudo apt-get update;

echo "Installing MySQL for XMPP server...";
#export DEBIAN_FRONTEND=noninteractive;
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server-5.6

# configure MySQL root password
mysqladmin -u root password "$PASSWORD"

# Comment-out bind-address in /etc/mysql/my.cnf to allow remote connections
sudo sed -i 's@bind-address@# bind-address@' /etc/mysql/my.cnf;

# restart db
sudo service mysql restart
echo "Finished installation of MySQL";

echo "Initializing database...";
mysql -u root --password="$PASSWORD" <<EOF
CREATE USER 'ejabberd'@'localhost' IDENTIFIED BY 'ejabberd';
GRANT ALL PRIVILEGES ON *.* TO 'ejabberd'@'localhost' WITH GRANT OPTION;
CREATE USER 'ejabberd'@'%' IDENTIFIED BY 'ejabberd';
GRANT ALL PRIVILEGES ON *.* TO 'ejabberd'@'%' WITH GRANT OPTION;
CREATE DATABASE ejabberd;
EOF

# Load database for XMPP server
wget https://raw.githubusercontent.com/dfserrano/KaleidoscopeOrchestration/master/chat/mysql.sql;
mysql -u ejabberd --password=ejabberd ejabberd < mysql.sql;
echo "Database ready";

echo "Installing ejabberd package...";
cd /home/ubuntu
sudo -u ubuntu wget https://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/15.06/ejabberd_15.06-0_amd64.deb;
sudo -u ubuntu mv downloads-action.php?file=%2Fejabberd%2F15.06%2Fejabberd_15.06-0_amd64.deb ejabberd_15.06-0_amd64.deb;
sudo -u ubuntu sudo dpkg -i ejabberd_15.06-0_amd64.deb;
echo "ejabberd package installed";

echo "Configuring ejabberd...";
# Change configuration file ejabberd.yml
sudo sed -i "/^hosts:/{n;s/.*/  - \"$DOMAIN\"/}" /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i "s@- \"admin\":.*@- \"admin\": \"$DOMAIN\"@" /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i 's@auth_method: internal@## auth_method: internal@' /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i 's@## auth_method: odbc@auth_method: odbc@' /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i 's@## odbc_type: mysql@odbc_type: mysql@' /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i "/odbc_type: mysql/{n;s/.*/odbc_server: \"$LOCAL_IP\"/}" /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i "/odbc_server: \"$LOCAL_IP\"/{n;s/.*/odbc_database: \"ejabberd\"/}" /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i '/odbc_database: \"ejabberd\"/{n;s/.*/odbc_username: \"ejabberd\"/}' /opt/ejabberd-15.06/conf/ejabberd.yml;
sudo sed -i '/odbc_username: \"ejabberd\"/{n;s/.*/odbc_password: \"ejabberd\"/}' /opt/ejabberd-15.06/conf/ejabberd.yml;

# Change hostname in ejabberdctl.cfg
sudo sed -i "s/#ERLANG_NODE=ejabberd@localhost/ERLANG_NODE=ejabberd@$LOCAL_IP/" /opt/ejabberd-15.06/conf/ejabberdctl.cfg;

# Change hostname in ejabberdctl
sudo sed -i "s/ERLANG_NODE=ejabberd@localhost/ERLANG_NODE=ejabberd@$LOCAL_IP/" /opt/ejabberd-15.06/bin/ejabberdctl;
echo "Finished configuration";

# Change file owners
sudo chown ubuntu:ubuntu /home/ubuntu/.erlang.cookie
sudo chown -R ubuntu:ubuntu /opt/ejabberd-15.06

echo "Attempting to run the chat server...";

sudo /opt/ejabberd-15.06/bin/ejabberdctl start;
sleep 5;
sudo /opt/ejabberd-15.06/bin/ejabberdctl status;

echo "Chat server running";
echo "Check chat server status using ejabberdctl status";

echo "Creating a copy of the cookie that can be copied by the slaves...";
sudo chmod 777 /home/ubuntu/.erlang.cookie;
cp /home/ubuntu/.erlang.cookie /home/ubuntu/.erlang.cookie.copy;
sudo chmod 700 /home/ubuntu/.erlang.cookie;

sleep 5;

# create admin user
sudo /opt/ejabberd-15.06/bin/ejabberdctl register admin $DOMAIN admin;

# echo "Admin Web UI available at http://$DOMAIN:5280/admin/";
