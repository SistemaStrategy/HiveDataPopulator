#HiveDataPopulator
In order to have a test database for API testing purpose, here is some easy steps to follow. These steps create and populate a table in hive using a random data generator scipt.

##Prerequisite
* Have a user able to upload / move file into HDFS
* Have a beeline CLI, available with Cloudera 5, or a hive CLI (deprecated for Cloudera 5 users, use beeline instead)

##Steps
1. Generate a random csv file using the 'random_csv_generator' script, passing in argument the number of row generated
```
./random_csv_generator.sh 100000000  
```
2. Move the csv file to hdfs with the appropriate user (in my case root)
```
sudo hdfs dfs -put random_values.csv /user/root
```
3. Create the table in hive and load the csv file with the appropriate user
	..* Connect to hive using beeline (**specify auth=noSasl if so, else specify nothing**)
	```
	!connect jdbc:hive2://vm-cluster2-node1:10000/;auth=noSasl root root org.apache.hive.jdbc.HiveDriver
	```
	..* Create database if not exists 
	```
	CREATE DATABASE IF NOT EXISTS test;
	```
	..* Specify the database to use
	```
	USE test;
	```
	..* Create the table (**\073** is the OCT code for **;**)
	```
	CREATE TABLE random (col1 string,col2 string,col3 int) row format delimited fields terminated by '\073' stored as textfile;
	```
	..* Load csv file data into the created table
	```
	LOAD DATA INPATH '/user/root/random_values.csv' OVERWRITE INTO TABLE random;
	```