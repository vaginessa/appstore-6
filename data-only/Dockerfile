FROM ubuntu

MAINTAINER Keiichiro Ono <kono@ucsd.edu>

RUN apt-get update && apt-get install -y wget

RUN mkdir /var/lib/mysql && mkdir /var/www && mkdir /var/www/CyAppStore
RUN mkdir /var/www/CyAppStore/media

WORKDIR /var/www/CyAppStore/media

ADD ./media /var/www/CyAppStore/media

CMD ["true"]