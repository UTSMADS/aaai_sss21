DROP DATABASE db_name;
CREATE DATABASE db_name;
CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'passwordGoesHere';
GRANT ALL PRIVILEGES ON db_name . * TO 'db_user'@'localhost';
FLUSH PRIVILEGES;
