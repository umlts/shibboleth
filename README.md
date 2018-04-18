Shibboleth on CentOS 7
======================

Setup scripts for configuring Shibboleth on CentOS 7. 

Execute `./install/install.sh` 
to install Apache and Shibboleth and set up a basic configuration.

The folder `/var/www/html/secure` holds an `index.php` file for testing. 
This folder is not really neccessary. Shibboleth protects everything that 
has a path which starts with `/secure/` per default (see `/etc/httpd/conf.d/shib.conf`).

## Manual changes

`/etc/shibboleth/shibboleth2.xml` needs to be adapted, change the domain
names in line 24 and 25 to:

	entityID="https://www.yourdomainname.com/shibboleth"
	homeURL="https://www.yourdomainname.com/"


## SSL Certificates and Virtual hosts

The script takes certificates, keys and the certificate chain files form 
the `install/certs` folder, moves them to the appropriate folders on the 
server and resets the SELinux file rights.

It creates the Virtual Host config files in `/etc/httpd/sites-available` and
adds links to them in the `/etc/httpd/sites-enabled` folder.

To do all this properly, the files must follow this naming convention:

* Certificate: `www.domainname.com.cert.cer`
* Key: `www.domainname.com.key`
* Chain file: `www.domainname.com.interm.cer`

## Using existing Shibboleth keys

If you want to reuse Shibboleth key files you already created, put the files
into the `install/certs` folder. The scripts will replace the default keys
with the ones from this directory.

The files need to be named `sp-key.pem` and `sp-cert.pem`.

## Using vagrant

Install VirtualBox & Vagrant. Run `vagrant up` to create the VM. The install
scripts gets executed automatically.

In case vagrant complains about a missing Guest Additions, try running 
`vagrant plugin install vagrant-vbguest`.

Port 80 is forwarded to Port 5080: <http://localhost:5080/> ,
Port 443 to 5443: <https://localhost:5443/>

Ports 80 and 443 are privileged on Linux machines. You need to be root to use
them. This can be done with SSH port forwarding:

`sudo ssh -p 2222 -gNfL 80:localhost:80 vagrant@localhost -i .vagrant/machines/default/virtualbox/private_key`

and

`sudo ssh -p 2222 -gNfL 443:localhost:443 vagrant@localhost -i .vagrant/machines/default/virtualbox/private_key`

Get the metadata here: <https://localhost:5443/Shibboleth.sso/Metadata>

