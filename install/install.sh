#!/bin/bash

SCRIPTDIR=$(dirname "$0")
DATE=$( date +%d-%m-%y )


###################################
#
# Check environment
#
###################################

# Check if root
if ! [ $(id -u) = 0 ]; then
   echo "You need root permissions to run this."
   exit 1
fi

# Check if yum installed
if ! [ $( which yum ) ]; then
   echo "Yum Package Manager not found. Weird."
   exit 1
fi

# Is this CentOS 7?
if ! [ -f "/etc/centos-release" ]; then
    echo "Warning: This seems not to be a CentOS environment."
else
    CENTOS_VER=$( grep -o "release [0-9]*" "/etc/centos-release"| grep -o "[0-9]*" )
    if ! [ $CENTOS_VER = 7 ]; then
        echo "Warning: This scripts is meant to be used with CentOs version 7."
        echo "This seems to be CentOs version $CENTOS_VER."
    fi
fi


###################################
#
# Set up OS, install basics
#
###################################

# Clean all cached metadata. Update the repos & packages
yum clean metadata
yum clean all
yum check-update
yum update

# Install needed packages
yum -y install \
    httpd \
    php \
    wget \
    yum-plugin-priorities \
    deltarpm


###################################
#
# Set up Shibboleth
#
###################################

# Set up repository
wget \
    "https://shibboleth.net/cgi-bin/sp_repo.cgi?platform=CentOS_7" \
    -O "/etc/yum.repos.d/shibboleth.repo"

# Install shibboleth
yum -y install shibboleth.x86_64

# Shibboleth is using some custom versions of a couple of
# libraries. Make sure they get used.
if ( shibd -t | grep "libcurl lacks OpenSSL-specific options" )
then
    echo "Include Shibboleth's custom libraries."
    echo "/opt/shibboleth/lib64" | tee "/etc/ld.so.conf.d/opt-shibboleth.conf"
    ldconfig

    shibd -t | grep "libcurl lacks OpenSSL-specific options" \
        && echo "Including libraries failed. Continuing anyway."
fi

# Create a backup of the config files we will change
cp "/etc/shibboleth/shibboleth2.xml" "/etc/shibboleth/shibboleth2.backup-$DATE.xml"
cp "/etc/shibboleth/attribute-map.xml" "/etc/shibboleth/attribute-map.xml.backup-$DATE.xml"

# Overwrite the shibboleth generated certificate (if given)
find "$SCRIPTDIR/certs" -type f -name "sp-*.pem" -exec cp --backup=numbered -- {} /etc/shibboleth \;

# Overwrite the config files with our settings
cp "$SCRIPTDIR/conf/shibboleth2.xml"  "/etc/shibboleth/shibboleth2.xml"
cp "$SCRIPTDIR/conf/attribute-map.xml"  "/etc/shibboleth/attribute-map.xml"


###################################
#
# Set up SSL for Apache
#
###################################

# Install Apache's mod_ssl
yum -y install mod_ssl openssl

# Debianize CentOs' Apache config a little:
# Create folders for sites / vhost configuration files
mkdir -p "/etc/httpd/sites-available"
mkdir -p "/etc/httpd/sites-enabled"

# Set up the vhosts if certificates are given
$SCRIPTDIR/set-up-vhosts.sh

# Make a test folter
mkdir -p "/var/www/html/secure"
echo "<h1>Logged in</h1><pre><?php print_r( \$_SERVER ); ?></pre>" | tee "/var/www/html/secure/index.php"

# Open the ports 80 and 443
if ! ( sudo firewall-cmd --state 2>&1 | grep -e "not running" ); then
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --zone=public --add-port=443/tcp --permanent
fi


###################################
#
# Restart the services
#
###################################

# Start the services
apachectl start
systemctl start shibd.service

# Set up daemons so they start on reboot
chkconfig httpd on
chkconfig shibd on
