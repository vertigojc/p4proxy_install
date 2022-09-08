# p4proxy_install
Bash script to quickly install helix-proxy on Ubuntu or CentOS

## Configuration
Make a copy of the p4p_install_template.sh and adjust the configuration variables at the top to fit your desierd setup. 

The only VAR that is absolutely necessary to change is the P4TARGET, which needs to be set to the address and port of the Helix Core server that this will be a proxy for. Be sure to include ssl: at the beginning if your server uses that and include the port number at the end.

## Run
Once it's configured, just run the bash script as the root user. 
It will create a perforce user, and register the proxy as a service with p4dctl, to make it easier to start and stop.

I have tested it on Centos 7 and Ubuntu 20.04 but it should also work on other versions of each.

