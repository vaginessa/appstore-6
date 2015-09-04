# Cytoscape App Store Site Administration

## _Contact Us_ emails

When a user fills out the form on the "Contact Us" page, the site sends an email to the site administrator's email address (defined in {{{conf.emails.CONTACT_EMAIL}}}). This email is sent out by the automated email account defined in {{{conf.emails.EMAIL_HOST_USER}}}. Thus, when the administrator receives the email, it will be from the automated email account, ''not'' from the user who filled out the "Contact Us" form. The first line in the email contains the user's email address.

When responding to "Contact Us" emails, remember to change the reply address to the user's email address.

## 2.x plugin submissions

2.x plugins are managed by UCSD's chianti server. When a developer submits a 2.x plugin, it goes to chianti, ''not'' to the App Store. When a plugin submission is approved, plugins.xml is updated, and an automatic email is sent by Barry.

To update the app page to reflect the update to plugins.xml:

 1. Go to the App Store and make sure you're signed in a staff account.
 1. In the user menu, click "2.x Plugin Management".
 1. In the plugin name field, enter the name of the 2.x plugin whose page you want to update.
 1. The page will present details about the plugin it obtained from plugins.xml. Check these details.
 1. If the details are correct, click on the blue button on the bottom right.

## 3.0 app submissions

When a jar is submitted to the App Store, the site sends an automated email to the administrator's email address (defined in {{{conf.emails.CONTACT_EMAIL}}}). Even if the app is not approved in the final step by the author, the administrator receives an email. This is done so that the administrator can monitor all submissions.

If an app page already exists for the 3.0 jar submission, the new release becomes immediately available. The administrator will receive an automated email about the submission.

If the app is new, the jar submission requires approval by staff. Sign in as staff, then go to the App Store site. In the user menu on the top right of the page, choose "Pending Apps". At this page, staff can approve an app. Approving an app sends an automatic email to the author and doesn't require any additional work. If the jar is not satisfactory, it can be rejected. No automatic email is sent to the author if the jar is rejected. This is because rejections happen when a jar is malformed and require an individualized email to the author.

# App Store Code Structure

## Terminology

 * ''Django app'': Django organizes websites into separate modules called apps. Each app has its own directory at the top level typically containing files like {{{__init__.py}}}, {{{model.py}}}, and {{{views.py}}}.
 * ''templates'': HTML files with placeholders, which Django processes by filling in Python code.
 * ''static files'': general website files (images, Java Script, CSS) that are served as is without any processing from Django.
 * ''media files'': general website files referenced by the database; they are served as is without any processing from Django.
 * ''mod_wsgi'': Apache module that interfaces with Python.

## Explanation of important files

### Configuration Files

 * {{{settings.py}}}: Django settings file for configuring things like the database, location of templates, static files, and so on.
 * {{{urls.py}}}: the general URL layout of the entire site. Each URL entry in this file delegates URL paths to each Django app.
 * {{{django.wsgi}}}: the configuration file used when the App Store is deployed to an Apache server using mod_wsgi.


### Django Apps

 * {{{apps}}}: navigation of Cytoscape apps and app pages
 * {{{users}}}: user login/logout
 * {{{search}}}: free text searching
 * {{{backend}}}: JSON representation of 3.0 apps; used by the App Manager in Cytoscape 3.0+
 * {{{help}}}: about, contact us, getting started pages
 * {{{submit_app}}}: Cytoscape 3.0 app submission pages and jar verification
 * {{{download}}}: for downloading releases and tracks download stats for apps

### Other Directories

 * {{{templates}}}: Templates used throughout the App Store.
 * {{{static}}}: Each subdirectory has static files for a Django app. The {{{common}}} subdirectory has static files that belong to the entire site. When deploying the site to Apache, Apache should directly serve these files instead of through Django.
 * {{{util}}}: small utility functions used throughout the site's code
 * {{{dbmigration}}}: scripts that directly update SQL tables after changes had been made to database models; only needed when needing to migrate old versions of SQL database backups
 * {{{conf}}}: individual configuration files

### Backup System

 * {{{jeff@pinscher.ucsf.edu}}}: Current account and server hosting the App Store.
 * {{{/home/jeff/backup_cyappstore}}}: Dir containing backup script and latest backup SQL and TGZ. 
 * {{{backupdb.sh}}}: Backup script run by cron job, daily at 12:03am. The script performs a sqldump of the "cyappstore" database, then {{{tar cfz}}}, then {{{scp}}} both files to {{{jeff@pointer.ucsf.edu:/home/jeff/backup_cyappstore/}}}, where the last 2 weeks' worth of SQL and TGZ files are maintained by the {{{prune_cyappstore}}} script.


# App Store Software Dependencies

The App Store requires the following software packages. If you're on a Mac, this can be installed with [[http://mxcl.github.io/homebrew/|Homebrew]]. If you're on Linux, use your distribution's package manager.

Note that the versions specified here are not mandatory. They only indicate the version with which I've tested the App Store.

 * Python 2.6
 * xapian 1.2.13 (free-text searching)
 * xapian-bindings 1.2.13
   * This package is not available through Homebrew. The package must be [[http://oligarchy.co.uk/xapian/1.2.13/xapian-bindings-1.2.13.tar.gz|downloaded]] and installed manually. When running the `configure` script, make sure to add the `--with-python` argument: `./configure --with-python`
 * libjpeg 8d (used by PIL)
 * libpng 1.5.14 (also used by PIL)
 * GeoIP 1.4.8 (converts IP addresses to geographical locations)

The following Python packages are also required. Each can be installed with `pip install`. If you don't have `pip`, type: `easy_install pip`.

 * Django 1.4.5
 * MySQL-Python (aka MySQLdb; can be installed with Debian/Ubuntu's package manager; Django uses this to connect to the MySQL database)
 * PIL 1.1.7 (can be installed with Debian/Ubuntu's package manager; needed to scale icon and screenshot image files)
   * PIL ''must'' be built the JPEG support. At the end of PIL's installation, you'll see a printout titled `PIL 1.1.7 SETUP SUMMARY`. This must list JPEG as supported.
 * django-social-auth 0.7.23 (aka social_auth; allows users to log in with their Google accounts)
 * IPython -- optional (can be installed with Debian/Ubuntu's package manager; very useful for debugging)


## Testing App Store Software Dependencies

Run the `test_dependencies.py` script like so:

    {{{
python external_scripts/test_dependencies.py}}}

Test the GeoIP library:
    {{{
python manage.py test_geoip}}}

'''Note''': this script can only be run ''after'' the Django project has been configured.

= Migration =

If you want to move the App Store to another machine, here is what to do:

 1. Install the needed libraries on the new machine by following the instructions in the *App Store Software Dependencies* section above.

 1. Check out the App Store GitHub repository to the new machine: [[http://github.com/cytoscape/appstore]]

 1. In the `conf` directory, make a copy of each `-template.py` file, removing the `-template.py` portion of the file name (e.g. `cp apikeys-template.py apikeys.py`). Open each template file and fill in the fields. Use the old machine's configuration if necessary. Do the same for `maven-app-repo-settings-template.xml` in the parent directory.

 1. In the `downloads/geolite` directory, type `make`. This will download the needed !GeoLite data files. (!GeoLite maps IP addresses to geographical locations.)

 1. Create the following daily cron jobs on the new machine:

    * Database backups described above in the subsection ''Backup System''.
    * Free text search reindexing: the crob job should run `make index` in the App Store directory.

 1. Take a snapshot of the database using `mysqldump` then load it to the new machine's database:

    {{{
# Run this on the old machine
mysqldump -u USER_NAME DB_NAME > CyAppStoreDbDump.sql

# Transfer CyAppStoreDbDump.sql from the old to new machine

Run this on the new machine:

```
mysql -u USER_NAME DB_NAME < CyAppStoreDbDump.sql
```

 1. Create an entry in Apache's `sites-enabled` directory for the App Store. Use the old machine's entry if necessary.

 1. Restart Apache and run the test protocol that's described below.

# How requests are handled

{{{
         ||             |                               |                    |                    |            ||
Request=>|| ==Apache==> | == sites-enabled/appstore ==> | == django.wsgi ==> | == settings.py ==> | == urls.py ||
         ||             |                               |                    |                    |            ||
}}}

 1. An HTTP request is made to the Apache server.
 1. Apache looks in {{{/etc/apache2/sites-enabled}}} to see how to handle the request. The {{{appstore}}} configuration file is set to handle requests made to {{{http://apps.cytoscape.org}}}.
 1. {{{appstore}}} tells Apache to use mod_wsgi. mod_wsgi runs a Python interpreter within Apache. {{{appstore}}} tells mod_wsgi to start Python with {{{/var/www/CyAppStore/django.wsgi}}}.
 1. {{{django.wsgi}}} starts the Django library. It also tells Django the location of {{{settings.py}}}, which Django needs to start the site.
 1. {{{settings.py}}} contains the location of {{{urls.py}}} (defined in the {{{ROOT_URLCONF}}} variable), which is a list of URLs (in the form of regular expressions) and the Python functions that handle them.
 1. {{{urls.py}}} in the top directory of the App Store merely imports additional URLs from each Django app. It dispatches the request to the appropriate function that is designated to handle requests for a given URL. Functions are defined in the {{{views.py}}} file in each Django app.
 1. The handler function returns with a processed HTML page.

# Debugging

 1. {{{/etc/apache2/sites-enabled/appstore}}}
  This file tells Apache and mod_wsgi where to find the site. The most important line is this:
  {{{
WSGIScriptAlias / /var/www/CyAppStore/django.wsgi
}}}
  This tells Apache and mod_wsgi where to locate the site code. Make sure the path to {{{django.wsgi}}} is correct.

 1. {{{/var/www/CyAppStore/django.wsgi}}}
  This file invokes Django's WSGI handler. It needs to correctly reference {{{settings.py}}} to start the site. Make sure these two lines are correct:
  {{{
SITE_PARENT_DIR = '/var/www'
SITE_DIR = filejoin(SITE_PARENT_DIR, 'CyAppStore')
}}}
  To check if these variables are being defined correctly, you can launch a separate Python interpreter and enter these lines:
  {{{
from os.path import join as filejoin
SITE_PARENT_DIR = '/var/www'
SITE_DIR = filejoin(SITE_PARENT_DIR, 'CyAppStore')
}}}
  Then check if the variables {{{SITE_PARENT_DIR}}} and {{{SITE_DIR}}} are correct.

 1. {{{/var/www/CyAppStore/settings.py}}}
  This file is pretty complicated. But if you've checked everything at this point, here's some ways to pinpoint problems in {{{settings.py}}}.
   a. If you're getting an HTTP 500 error, you can get the stack trace by turning on debug mode then reloading the page. Note that debug mode exposes sensitive information about the site to the public. Make sure to keep debug mode off as much as possible. Change to following line to {{{True}}}:
   {{{
DEBUG = False
}}}

   a. You can poke at the code by running a Python shell. Enter this command at the shell prompt in the same directory as {{{settings.py}}}:
   {{{
python manage.py shell
}}}
   You can check to see if the site's code is working correctly without having debug mode on. For example, to see if the list of all apps is working,  enter this into the Python interpreter:
   {{{
from apps.models import App
App.objects.all()
}}}

   a. The SQL database settings are specified by the {{{DATABASES}}} variable:
   {{{
DATABASES = {
        'default': deploy_database
}
}}}
   Make sure that {{{'default'}}} is pointing to te correct dictionary:
   {{{
deploy_database = {
        'ENGINE':   'django.db.backends.mysql',
        'NAME':     ...
        'USER':     ...,
        'PASSWORD': ...
}
}}}

   a. If you're getting database errors, enter this command at the shell prompt in the same directory as {{{settings.py}}}:
   {{{
python manage.py dbshell
}}}
   If you're able to get a SQL prompt, that means Django can connect to the SQL database.

   a. If you make changes to a Python file but you're not seeing the changes taking effect, you may have to delete all the {{{.pyc}}} files. To do so, type this:
   {{{
make svnclean
}}}

# Tips

 * You can reindex the text search engine with this command:
 {{{
make index
}}}

 * If you edit any Python files and need it to be refreshed by Apache, you will need to remove all pyc files:
 {{{
make nopyc
}}}

# App Store Test Protocol

 1. Does the front page load?
 1. Does "All Apps" load?
     1. Does sorting work as expected?
 1. Does a category load?
 1. Does a 2.x plugin page load? (e.g. `/apps/psicquicuniversalclient`)
     1. Does plugin downloading work?
     1. Does "Search for posts" work?
     1. Does ratings work?
 1. Does a 3.x app page load? (e.g. `/apps/cluego`)
     1. Do release downloads work?
     1. When a release is downloaded, is it reflected in the stats page?
 1. Does app page editing work?
     1. Icon?
     1. Any link field?
     1. Details editing?
     1. Deleting a 3.0 release?
         1. Does the release still show in the download stats?
         1. Does the release no longer show in the app page?
         1. Does the release no longer show in the backend?
         1. Does depending on the deleted release fail?
         1. Does submitting a jar with the same name and version succeed?
 1. Does search work?
 1. Do app author pages work? (e.g. `/apps/with_author/John%20"Scooter"%20Morris`)
 1. Does the "About" page load?
 1. Does the "Contact Us" page load and work?
 1. Does the `/backend/all_apps` page work?
     1. Does it refer accurately to icon and release URLs?
 1. Do the admin pages load?

## App Submission Test Protocol

App submissions will principally test the manifest file. The following snippets are for jars created with the manifest files listed below.

To create an empty jar with just a given manifest, first make sure to have an empty file in the current directory. This is because `jar` requires at least one input file (besides the manifest) to create a jar. Run this command to create the jar:
{{{
jar cmf manifest jar-name.jar empty}}}

### Empty manifest test

This should fail: no `Cytoscape-App-Name` in the manifest.

### Simple app test: no version

This should fail: no `Cytoscape-App-Version` in the manifest.

Manifest:
{{{
Cytoscape-App-Name: blah
}}}

### Simple app test: no API compatibility

This should fail: no `Cytoscape-API-Compatibility` in the manifest.

Manifest:
{{{
Cytoscape-App-Name: blah
Cytoscape-App-Version: 1.0
}}}

### Simple app test: new app

 * This should succeed and require adding a new app page.
 * After submission, the admin should receive an email about the submission. It should be listed in the Pending Apps page.
 * Go back to the "Confirmation" page, then click "No, cancel it". It should no longer be listed in Pending Apps.
 * Resubmit the app, and accept it. It should successfully create an app page.
 * An email from the account in `conf/emails.py/EMAIL_ADDR` should have been sent to the app author confirming the app.
 * The new app page must have the submitter's email address listed as an editor.

Manifest:
{{{
Cytoscape-App-Name: blah
Cytoscape-App-Version: 1.0
Cytoscape-API-Compatibility: 3.0
}}}

### Simple app test: new release

This should succeed and not require admin approval. It should still send an email to the admin about the submission.

Manifest:
{{{
Cytoscape-App-Name: blah
Cytoscape-App-Version: 2.0
Cytoscape-API-Compatibility: 3.0
}}}


### Simple app test: no authorization

Submit the jar with the same manifest as above but under a different, non-admin account. Submission should be rejected.

### OSGi bundle: no name

This should fail: no `Bundle-Name`.

Manifest:
{{{
Bundle-SymbolicName: blah
}}}

### OSGi bundle: no version

This should fail: no `Bundle-Version`.

Manifest:
{{{
Bundle-SymbolicName: blah
Bundle-Name: blah
}}}

### OSGi bundle: no Cytoscape imports

This should fail: no Cytoscape packages in `Import-Package`.

Manifest:
{{{
Bundle-SymbolicName: blah
Bundle-Name: blah
Bundle-Version: 3.0
Import-Package: xyz,abc
}}}

### OSGi bundle: no Cytoscape version in imports

This should fail: no Cytoscape packages in `Import-Package`.

Manifest:
{{{
Bundle-SymbolicName: blah
Bundle-Name: blah
Bundle-Version: 3.0
Import-Package: org.cytoscape.a, org.cytoscape.b
}}}

### OSGi bundle: new release

This should succeed.

 - The minimum Cytoscape version ''must'' be `3.5`.

Manifest:
{{{
Bundle-SymbolicName: blah
Bundle-Name: blah
Bundle-Version: 3.0
Import-Package: org.cytoscape.a;version="(3.0,4]",
  org.cytoscape.b;version="(3.5,4]"
}}}

### OSGi bundle: export package

This should succeed and ask for a pom and Javadocs.

Manifest:
{{{
Bundle-SymbolicName: blah
Bundle-Name: blah
Bundle-Version: 4.0
Import-Package: org.cytoscape.a;version="(3.0,4]",
  org.cytoscape.b;version="(3.5,4]"
Export-Package: blah
}}}

### OSGi bundle: deleted dependency

Delete an existing release. Then try to submit an app that depends on it. This should fail.

Manifest:
{{{
Bundle-SymbolicName: blah
Bundle-Name: blah
Bundle-Version: 3.0
Import-Package: org.cytoscape.a;version="(3.0,4]",
  org.cytoscape.b;version="(3.5,4]"
Cytoscape-App-Dependencies: GeneMANIA;3.0.0.beta1
}}}

### OSGi bundle: multiple dependencies

Submission should succeed. After submission, GeneMANIA and ClueGO must list blah as a dependency.

Manifest:
{{{
Bundle-SymbolicName: blah
Bundle-Name: blah
Bundle-Version: 5.0
Import-Package: org.cytoscape.a;version="(3.0,4]",
  org.cytoscape.b;version="(3.5,4]"
Cytoscape-App-Dependencies: GeneMANIA;3.0.0.beta2, ClueGO;2.0.0
}}}