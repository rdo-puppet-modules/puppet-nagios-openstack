# Class for Nagios Remote Plugin Executor
class nagios::client (
  $host_ip = undef,
  $nagios_server_host = undef,
) {

  package { ['nrpe', 'nagios-plugins-load', 'nagios-plugins-disk']:
    ensure => present,
  } ->

  file_line { 'allowed_hosts':
    path   => '/etc/nagios/nrpe.cfg',
    match  => 'allowed_hosts=',
    line   => "allowed_hosts=127.0.0.1,${nagios_server_host}",
  } ->

  file_line {'check_disk_var':
    path => '/etc/nagios/nrpe.cfg',
    line => 'command[check_disk_var]=/usr/lib64/nagios/plugins/check_disk -w 10% -c 5% -p /var',
  } ->

  file_line {'virsh_nodeinfo':
    path => '/etc/nagios/nrpe.cfg',
    line => 'command[virsh_nodeinfo]=/usr/lib64/nagios/plugins/virsh_nodeinfo',
  } ->

  file {'/usr/lib64/nagios/plugins/virsh_nodeinfo':
    mode    => 755,
    seltype => 'nagios_unconfined_plugin_exec_t',
    content => template('nagios/virsh_nodeinfo.erb')
  } ~>

  service {'nrpe':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  firewall {'001 Nagios NRPE incoming':
    proto  => 'tcp',
    dport  => '5666',
    action => 'accept',
  }

  if "${settings::storeconfigs_backend}" == 'puppetdb' {
    @@nagios_host {"$::fqdn":
      address    => "$host_ip",
      hostgroups => "${openstack_services_enabled}",
      use        => 'linux-server',
    }
  }
  else {
    $nulle = nagios_host_add("$::fqdn",
      { address    => "$host_ip",
        hostgroups => "${::openstack_services_enabled}",
        use        => 'linux-server',
      }
    )
  }
}
