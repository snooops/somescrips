#!/bin/bash
###########################
#
# (c) Dennis Meyer
# snooops84@gmail.com
#
# 
# Versions:
# 0.1   - Initial Release
###########################

# amount of days to store old backups
keepbackups=7

# backup directory
targetDir="/var/backups/mysqlbackup"


# date of today
now=$(date +"%d%m%Y")

mkdir $targetDir/$now -p

# TODO: need to be replaced with a better find
# removing old backups
oldest=$(date +"%d%m%Y" -d "$keepbackups days ago")
rm -r $targetDir/$oldest


#check if binlog is active
binlog=$(mysql -e "show global variables like 'log_bin'\G" | grep Value: |awk -F ":" '{print $2}')

if [ $binlog = "OFF" ]
then
    mysqlparambinlog=""
else
    #getting binlog position inside the dump
    mysqlparambinlog="--master-data=1"
fi

#get all databases to loop them
databases=$(mysql -e "show databases" |tail -n +2)
for database in $databases; do

    # create database based dump   
    mysqldump $database --single-transaction $mysqlparambinlog |gzip > $targetDir/$now/$database.sql.gz
done
