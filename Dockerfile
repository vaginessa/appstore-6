# Docker file for Cytoscape App Store
# 
# This version is a straight port from the original version.
# i.e., very monorithic...
#
# The container has the following dependencies
#
# - Python 2.7
# - Django
# - Apache2.x
# - Java 8 and Maven
#
# by Keiichiro Ono (kono@ucsd.edu)
#

FROM python:2.7

MAINTAINER Keiichiro Ono <kono@ucsd.edu>

########### Install Java 8 and Maven ##################
RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' \
			> /etc/apt/sources.list.d/jessie-backports.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8
ENV JAVA_VERSION 8u66
ENV JAVA_DEBIAN_VERSION 8u66-b01-1~bpo8+1
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
		openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
		ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Install Maven
ENV MAVEN_VERSION 3.3.3
RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven


########### Install dependencies used by Django App ##################
RUN apt-get install -y \
		build-essential \
		python-imaging \
		geoip-bin geoip-dbg libgeoip-dev \
		unzip curl zlib1g-dev g++ uuid-dev \
		apache2 apache2-mpm-prefork apache2-prefork-dev \
		libapache2-mod-wsgi vim && \
		mkdir /xapian

# Download and compile Python bindings for xapian.
# Ubuntu package version does not work!
WORKDIR /xapian
RUN apt-get install -y python-xapian libxapian-dev
RUN curl -O http://oligarchy.co.uk/xapian/1.2.19/xapian-bindings-1.2.19.tar.xz && \
	tar xf /xapian/xapian-bindings-1.2.19.tar.xz

WORKDIR /xapian/xapian-bindings-1.2.19
RUN ./configure --with-python && make && make install


############# Install required Python packages through PyPI #############

# Use Pillow instead of olf PIL
RUN pip install mod_wsgi Django==1.4.5 MySQL-Python django-social-auth Pillow GeoIP


# Copy local code base to the container
# Note that CyAppStore is the top-level directory for the entire application
RUN mkdir /var/www/CyAppStore && \
	mkdir /var/www/CyAppStore/logs && \
	mkdir /var/www/CyAppStore/media
WORKDIR /var/www/CyAppStore
ADD . /var/www/CyAppStore

# This credentials directory should be copied from your secret directory!
ADD ./credentials/*.py /var/www/CyAppStore/conf/

# Download geoip files from remote server.
WORKDIR /var/www/CyAppStore/download/geolite
RUN make

# Verify the dependencies.  This does not work without 
WORKDIR /var/www/CyAppStore
RUN python external_scripts/test_dependencies.py

# TODO: Make this checker work
#RUN python manage.py test_geoip

################ Apache2 setup ################

# Copy setting file
ADD ./credentials/appstore.conf /etc/apache2/sites-available/

# Disable default site
RUN a2dissite 000-default

# Enable App Store Django web app
RUN a2ensite appstore

EXPOSE 80

# Run the Apache server in the script.
CMD ["./run.sh"]
