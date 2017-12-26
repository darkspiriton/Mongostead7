echo "MongoDB install  script with PHP7 & nginx [Laravel Homestead]"
echo "By Zakaria BenBakkar, @zakhttp, zakhttp@gmail.com"

echo "Importing the public key used by the package management system";
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6;

echo "Creating a list file for MongoDB.";
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list;

echo "Updating the packages list";
sudo apt-get update;

echo "Install the latest version of MongoDb";
sudo apt-get install -y mongodb-org;

echo "Fixing the pecl errors list";
sudo sed -i -e 's/-C -n -q/-C -q/g' `which pecl`;

echo "Installing OpenSSl Libraries";
sudo apt-get install -y autoconf g++ make openssl libssl-dev libcurl4-openssl-dev;
sudo apt-get install -y libcurl4-openssl-dev pkg-config;
sudo apt-get install -y libsasl2-dev;

echo "Installing PHP7 mongoDb extension";
sudo pecl install mongodb;

echo "adding the extension to your php.ini file";
sudo touch /etc/php/7.1/mods-available/mongodb.ini
sudo echo "; configuration for php mongo module\n; priority=30\nextension=mongodb.so" >> /etc/php/7.1/mods-available/mongodb.ini
sudo ln -s /etc/php/7.1/mods-available/mongodb.ini 30-mongodb.ini

echo "Add mongodb.service file"
cat >/etc/systemd/system/mongodb.service <<EOL
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target
EOL

# Change mongoDB Listening IP Address from local 127.0.0.1 to All IPs 0.0.0.0
sudo sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mongod.conf

sudo systemctl start mongodb
sudo systemctl status mongodb
sudo systemctl enable mongodb

echo "restarting The nginx server";
sudo service nginx restart && sudo service php7.1-fpm restart
