## SSL Configuration ##

The `alfresco::install::proxy` module takes an argument `ssl_cert_path` _(which 
is passed to it by `alfresco::init` and can be passed in there)_ and it expects
to find there a `.cert` file and a `.key` file named for your domain, so for 
example if your domain is 'demosite.orderofthebee.org' you would arrange for 
your key+cert files to be in the `ssl_cert_path` location and then puppet would try 
to retrieve:

    demosite.orderofthebee.org.key
    demosite.orderofthebee.org.cert

from the `ssl_cert_path` location.

If `ssl_cert_path` starts with "http" then puppet will attempt to download the 
files by appending `/demosite.orderofthebee.org.key` or `/demosite.orderofthebee.org.cert`
as appropriate to `ssl_cert_path`.

If no `ssl_cert_path` is given then new self-signed certificates will be generated

The domain name you use has to match the `domain_name` argument to init.pp