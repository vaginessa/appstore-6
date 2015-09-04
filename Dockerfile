# Docker file for Cytoscape App Store
#
# by Keiichiro Ono (kono@ucsd.edu)
#
FROM python:2.7

MAINTAINER Keiichiro Ono <kono@ucsd.edu>

# For Maven, which requires Java...
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

# Install system-level dependencies:
RUN apt-get update && apt-get install -y \
		build-essential \
		python-imaging \
		geoip-bin geoip-dbg libgeoip-dev \
		unzip

# Install xapian and python-binding manually...
RUN apt-get install -y curl zlib1g-dev g++ uuid-dev
RUN mkdir /xapian
WORKDIR /xapian

RUN apt-get install -y python-xapian libxapian-dev

RUN curl -O http://oligarchy.co.uk/xapian/1.2.19/xapian-bindings-1.2.19.tar.xz
RUN tar xf /xapian/xapian-bindings-1.2.19.tar.xz

WORKDIR /xapian/xapian-bindings-1.2.19
RUN ./configure --with-python && make && make install

# Install required Python packages
RUN pip install Django MySQL-Python django-social-auth Pillow


# Add this code base to the container
RUN mkdir /appstore
WORKDIR /appstore
ADD . /appstore/

# Build geoip
WORKDIR /appstore/download/geolite
RUN make

# Verify the dependencies
WORKDIR /appstore
RUN python external_scripts/test_dependencies.py
RUN python manage.py test_geoip