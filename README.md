#HiveDataPopulator
In order to have a test database for API testing purpose, here is some easy steps to follow. These steps create and populate a table into Hive using a random data generator scipt or a sqoop job to import data from MariaDB.

##Prerequisite 
* Random generator
  * Have a user able to upload / move file into HDFS
  * Have a beeline CLI, available with Cloudera 5, or a Hive CLI (deprecated for Cloudera 5 users, use beeline instead)
* Sqoop import
  * Sqoop installed
  * MariaDB installed

* Change the following variables in commands 
  * HIVE_SERVER_HOSTNAME
  * USER
  * PASSWORD
  * MARIADB_SERVER_HOSTNAME
  * MARIADB_TABLE_NAME
  * HIVE_TABLE_NAME


##Steps for random generator
1. Generate a random csv file using the 'random_csv_generator' script, passing in argument the number of row generated
  ```
  ./random_csv_generator.sh 100000000  
  ```

2. Move the csv file to hdfs with the appropriate user (in my case root)
  ```
  sudo hdfs dfs -put random_values.csv /user/root
  ```

3. Create the table in Hive and load the csv file with the appropriate user
	* Connect to Hive using beeline CLI (**specify auth=noSasl if so, else specify nothing**)
	  ```
	  > beeline
	  > Beeline version 1.1.0-cdh5.5.1 by Apache Hive
	  beeline> !connect jdbc:hive2://HIVE_SERVER_HOSTNAME:10000/;auth=noSasl USER PASSWORD org.apache.hive.jdbc.HiveDriver
	  ```
	  
	* Create database if not exists 
	  ```
	  > CREATE DATABASE IF NOT EXISTS test;
	  ```
	  
	* Specify the database to use
	  ```
	  > USE test;
	  ```
	  
	* Create the table (**\073** is the OCT code for **;**)
	  ```
	  > CREATE TABLE random (col1 string,col2 string,col3 int) row format delimited fields terminated by '\073' stored as textfile;
	  ```
	  
	* Load csv file data into the created table
	  ```
	  > LOAD DATA INPATH '/user/root/random_values.csv' OVERWRITE INTO TABLE random;
	  ```
	
##Steps for Sqoop import
1. First you need to modify the **my.cnf** file by replacing the bind address ```127.0.0.1``` by your hostname
2. Start the MariaDB deamon 
  ```
  sudo service mysql start
  ```
  
3. Create your database and insert your data
4. Grant all priviledge to the Sqoop user (the one running Sqoop for ETL, in my case root)
 ```
 GRANT ALL PRIVILEGES ON *.* TO 'USER_MARIADB'@'%' IDENTIFIED BY 'PASSWORD_MARIADB' WITH GRANT OPTION;
 ```
 
5. Copy mysql driver to lib folder of Sqoop 
 ```
 sudo cp mariadb-java-client-1.3.5.jar /opt/cloudera/parcels/CDH/lib/sqoop/lib/
 ```
 
6. Create Hive database
  * Connect to Hive using beeline CLI (**specify auth=noSasl if so, else specify nothing**)
    ```
    > beeline
    > Beeline version 1.1.0-cdh5.5.1 by Apache Hive
    beeline> !connect jdbc:hive2://HIVE_SERVER_HOSTNAME:10000/;auth=noSasl USER PASSWORD org.apache.hive.jdbc.HiveDriver
    ```
    
  * Create database if not exists 
    ```
    > CREATE DATABASE IF NOT EXISTS hivedbtest;
    ```
    
7. Create Hue user to be able to launch Sqoop and write to HDFS
  * Go to Hue WEB UI, Administration / Manage users (http://HUE_SERVER_HOSTNAME:8888/useradmin/users) and add a user as super-user and default group (the same you'll be executing Sqoop, in my case **root**)
8. Launch Sqoop import job
  ```
  sudo sqoop import --driver org.mariadb.jdbc.Driver --connect jdbc:mysql://MARIADB_SERVER_HOSTNAME:3306/userdb --username USER_MARIADB --password PASSWORD_MARIADB --table MARIADB_TABLE_NAME --hive-import --hive-table hivedbtest.HIVE_TABLE_NAME -m 1
  ```
  
  If you want to import the data as a text file and then create the database you can also use the command
  ```
  sudo sqoop import --driver org.mariadb.jdbc.Driver --connect jdbc:mysql://MARIADB_SERVER_HOSTNAME:3306/userdb --username USER_MARIADB --password PASSWORD_MARIADB --table MARIADB_TABLE_NAME --target-dir /mariadb_data --append
  ```
