#!/bin/bash

# Backup script from the data container

# Dump DB

docker exec -it appstore_mysql_1 mysqldump -u root --password=PW cyappstore > ./backups/CyAppStoreDbDump.sql

# Create media directory archive
docker run --volumes-from appstore_data_1 -v $(pwd)/backups:/backup ubuntu tar czvf /backup/media.tar.gz /var/www/CyAppStore/media

# Compy it to other server

## AWS

## UCSD

# Rotation
