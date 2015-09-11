#!/bin/bash

#python manage.py syncdb

# Change permissin of media directory
RUN groupadd mediausers && adduser www-data mediausers && \
	chgrp -R mediausers /var/www/CyAppStore/media && \
	chmod -R 770 /var/www/CyAppStore/media

apache2ctl -DFOREGROUND