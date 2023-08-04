#!/bin/bash
sudo su
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
chmod 777 /var/www/html
cd /var/www/html
echo "<!DOCTYPE html><html><head><title>Sales Department</title></head><body><h1>Sales Department</h1><p>This is the sales department web page.</p></body></html>" > sales.html
#!/bin/bash
INSTANCE_PUBLIC_IP=$(curl http://checkip.amazonaws.com)

# Step 1: Install OpenSSL
cd /
sudo yum install mod_ssl -y

# Step 2: Generate a self-signed Certificate Authority (CA) certificate
sudo openssl req -new -x509 -nodes -days 365 -subj "/CN=MyCA" -keyout ca.key -out ca.crt

# Step 3: Generate a private key for the server
sudo openssl genrsa -out private.key 2048

# Step 4: Generate a Certificate Signing Request (CSR) for the server
sudo openssl req -new -key private.key -out server.csr -subj "/CN=$INSTANCE_PUBLIC_IP"

# Step 5: Sign the server certificate with the CA certificate
sudo openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365

# Step 6: Copy the CA certificate and server certificate/key to the appropriate directories
sudo cp ca.crt /etc/pki/tls/certs/
sudo cp server.crt /etc/pki/tls/certs/
sudo cp private.key /etc/pki/tls/private/

# Step 7: Configure Apache to use the SSL certificate
sudo sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/pki/tls/certs/server.crt|" /etc/httpd/conf.d/ssl.conf
sudo sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/pki/tls/private/private.key|" /etc/httpd/conf.d/ssl.conf

# Step 8: Enable HTTPS and configure TLS
sudo sed -i "s|#LoadModule ssl_module modules/mod_ssl.so|LoadModule ssl_module modules/mod_ssl.so|" /etc/httpd/conf/httpd.conf
sudo sed -i "s|#Include conf/extra/httpd-ssl.conf|Include conf/extra/httpd-ssl.conf|" /etc/httpd/conf/httpd.conf

# Step 9: Restart Apache
sudo systemctl restart httpd
