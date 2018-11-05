echo "MongoDB install  script with PHP7 & nginx [Laravel Homestead]"
echo "By Zakaria BenBakkar, @zakhttp, zakhttp@gmail.com"
echo "Updated php7.2 & mongo4.0 by Cesar Moreno morenodev@gmail.com"

echo "Importing the public key used by the package management system";
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4;

echo "Creating a list file for MongoDB.";
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list

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
sudo touch /etc/php/7.2/mods-available/mongodb.ini
sudo echo "extension=mongodb.so" >> /etc/php/7.2/mods-available/mongodb.ini
sudo ln -s /etc/php/7.2/mods-available/mongodb.ini  /etc/php/7.2/fpm/conf.d/30-mongodb.ini
sudo ln -s /etc/php/7.2/mods-available/mongodb.ini  /etc/php/7.2/cli/conf.d/30-mongodb.ini

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

# Change mongoDB Listening PORT from 27017 to 37037
sudo sed -i 's/27017/37037/g' /etc/mongod.conf

sudo systemctl start mongodb
sudo systemctl status mongodb
sudo systemctl enable mongodb

echo "restarting The nginx server";
sudo service nginx restart && sudo service php7.2-fpm restart
