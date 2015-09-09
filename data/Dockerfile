FROM mysql:5.6

MAINTAINER Keiichiro Ono <kono@ucsd.edu>

RUN apt-get update && apt-get install -y curl


# Copy snapshot of existing app data into container

RUN mkdir /data
# Download current database from Amazon S3
#RUN curl

# https://s3-us-west-2.amazonaws.com/cytoscape/appstore/current/dump.sql
ADD ./dump.sql /data/
WORKDIR /data

# Create 
#RUN mysql -u root --password=appsrule cyappstore < dump.sql
