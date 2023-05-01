## Setting Up The Client VPN Endpoint Credentials
1.  Generate certs to be imported for Linux or Windows via the link below
    https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html
    Move all files to a specific folder of your choice. Mine is a /certs/ folder.

2.  Download the Client VPN File from the AWS Client VPN Endpoint dashboard.

3.  Add a subdomain name to the client vpn endpoint url on line 4 of the file.

4.  Add the certification authority certificate at the last line of the file.

5.  Add the client certificate on a new line of the Client VPN File.

6.  Import the file into your Open VPN app and connect.


The current aws_vpc_peering_connection_options resource has a bug. So I had a way around it to make it work. I raised an issue in the AWS provider repo, and will update my code if it gets approved.
