FROM ubuntu

MAINTAINER Keiichiro Ono <kono@ucsd.edu>

RUN apt-get update && apt-get install -y wget

RUN mkdir /var/lib/mysql && mkdir /var/www && mkdir /var/www/CyAppStore

# Download required data files: SQL DB and media files
RUN mkdir /tmp_data
WORKDIR /tmp_data

# Currently, this only works from EC2 instance
RUN wget http://chianti.ucsd.edu/~kono/data/appstore/cyappstore-media-150908.tgz
RUN wget http://chianti.ucsd.edu/~kono/data/appstore/dump.sql

# Move it 
RUN mv dump.sql /var/lib/mysql/

# Extract media files
RUN tar -xvf cyappstore-media-150908.tgz && mv ./var/www/CyAppStore/media /var/www/CyAppStore/
WORKDIR /var/www/CyAppStore/media

CMD ["true"]