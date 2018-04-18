#!/bin/bash
SCRIPTDIR=$(dirname "$0")

# Add including the sites' configurations in the main configuration
# file. Check if that has not been done before.
if ! ( grep "sites-enabled" "/etc/httpd/conf/httpd.conf" )
then
    # Create a backup of the original configuration
    cp "/etc/httpd/conf/httpd.conf" "/etc/httpd/conf/httpd.backup-$DATE.conf"

    # Add IncludeOptional statement
    echo "" >> "/etc/httpd/conf/httpd.conf"
    echo "# Include sites / vhosts" >> "/etc/httpd/conf/httpd.conf"
    echo "IncludeOptional sites-enabled/*.conf" >> "/etc/httpd/conf/httpd.conf"
fi

# Rename certs. Replace _ with .
CERT_FILES=$( find "$SCRIPTDIR/certs" -name *.csr -o -name *.key -o -name *.cer -o -name *.crt )
for CERT_FILE in $CERT_FILES
do
    NEW_NAME=$( echo $CERT_FILE | sed "s/_/./g" )
    test -f $NEW_NAME || mv -b $CERT_FILE $NEW_NAME;
done


# Copy from /certs to the their locations
find "$SCRIPTDIR/certs" -type f -name *.cer -exec cp {} /etc/pki/tls/certs \;
find "$SCRIPTDIR/certs" -type f -name *.crt -exec cp {} /etc/pki/tls/certs \;
find "$SCRIPTDIR/certs" -type f -name *.key -exec cp {} /etc/pki/tls/private \;
find "$SCRIPTDIR/certs" -type f -name *.csr -exec cp {} /etc/pki/tls/private \;

# Fix the SELinux contexts
restorecon -RvF "/etc/pki"

# Set up the configuration files for the domains
DOMAINS=$(
    find "$SCRIPTDIR/certs" -type f -name "*.key" \
    | sort \
    | uniq \
    | xargs --max-lines=1 basename \
    | sed "s/\.[a-z]*$//"
)

for DOMAIN in $DOMAINS
do
    sed "s/__DOMAIN__/$DOMAIN/" "$SCRIPTDIR/conf/001-default-ssl.conf" > "/etc/httpd/sites-available/$DOMAIN.conf"
    ln -s "../sites-available/$DOMAIN.conf" "/etc/httpd/sites-enabled/$DOMAIN.conf"
done
