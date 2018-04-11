Shibboleth CentOS
=================

Setup scripts for Shibboleth using CentOS 7. Execute `./install/install.sh` to install Apache and Shibboleth and set up a basic configuration.

The scripts creates a dummy SSL certificate which should be replaced by the actual certificate once the installation in done. The certificates are saved in `/etc/httpd/ssl-certs/`.

## Using vagrant

Install VirtualBox & Vagrant. Run `vagrant up` to create the VM.

Port 80 is forwarded to Port 5080: <http://localhost:5080/> , Port 443 to 5443: <http://localhost:5443/>

