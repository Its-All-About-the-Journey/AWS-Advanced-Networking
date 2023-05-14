output "Cloudfront_Distribution_Primary" {
  value = data.aws_cloudfront_distribution.s3_distribution.domain_name
}

output "ACM_Domain_Name" {
  value = aws_acm_certificate.cert.domain_name
}


/*
Let's assume you have the following values for the aws_acm_certificate.cert.domain_validation_options attribute:

aws_acm_certificate.cert.domain_validation_options = [
  {
    domain_name              = "example.com"
    resource_record_name     = "_acme-challenge.example.com"
    resource_record_value    = "ABC123DEF456"
    resource_record_type     = "TXT"
  },
  {
    domain_name              = "subdomain.example.com"
    resource_record_name     = "_acme-challenge.subdomain.example.com"
    resource_record_value    = "XYZ789UVW321"
    resource_record_type     = "TXT"
  },
]

The output will be:
fqdn = {
  "example.com"            = "_acme-challenge.example.com.example.com"
  "subdomain.example.com"  = "_acme-challenge.subdomain.example.com.example.com"
}

In this example, the FQDNs of the aws_route53_record resources are:

For the domain example.com, the FQDN is _acme-challenge.example.com.example.com.
For the domain subdomain.example.com, the FQDN is _acme-challenge.subdomain.example.com.example.com.

The expression key => record.fqdn creates a map where the key is the domain name (key), 
and the value is the FQDN (record.fqdn) of the aws_route53_record resource. 
It essentially constructs a new map using the domain name as the key and the FQDN as the value.
*/
