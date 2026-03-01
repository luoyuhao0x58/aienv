#! /bin/bash

# mysql
apt-get install -y default-mysql-client

# postgresql
apt-get install -y postgresql-client

# redis
apt-get install -y redis-tools

# mongodb
wget -qO- https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg
echo "deb [signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
apt-get update -y
apt-get install -y mongodb-mongosh