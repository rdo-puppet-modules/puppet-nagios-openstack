puppet-nagios-openstack
=======================

Nagios Puppet module for OpenStack 

Add nagios::client class to every OpenStack node to be monitored.  
This will define the host and its related OpenStack services definitions to be added to Nagios.

Use nagios::server class to setup a Nagios server.
The Nagios hosts definitions will be the collected with either:
- PuppetDB if it's configured
- A built-in mechanism definition sharing

The server catalog should be (re)applied after the OpenStack nodes have been deployed (or changed)
