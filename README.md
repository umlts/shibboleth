Shibboleth CentOS
=================

Setup scripts for Shibboleth using CentOS 7. Execute `./install/install.sh` to install Apache and Shibboleth and set up a basic configuration.

* The script creates a dummy SSL certificate which should be replaced by the actual certificate once the installation in done. The certificates are saved in `/etc/httpd/ssl-certs/`.
* The folder `/var/www/html/secure` holds a `index.html` file for testing. This folder is not really neccessary. Shibboleth protects everything that has a path which starts with `/secure/`.

## Using vagrant

Install VirtualBox & Vagrant. Run `vagrant up` to create the VM.

Port 80 is forwarded to Port 5080: <http://localhost:5080/> , Port 443 to 5443: <https://localhost:5443/>

Get the metadata here: <https://localhost:5443/Shibboleth.sso/Metadata>

### More information

More information on the configuration can be found here: <https://trac.lib.missouri.edu/lso/ticket/1624>
