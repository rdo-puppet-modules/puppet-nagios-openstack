# Openstack class for Nagios server
class nagios::server::openstack(
  $admin_password,
  $controller_ip,
  $nagios_group,
  $nagios_user,

  $neutron = true,
  $swift = true,
) {

  File {
    owner => $nagios_user,
    group => $nagios_group,
  }

  Nagios_command {
    target => '/etc/nagios/conf.d/commands.cfg',
  }

  Nagios_host {
    target => '/etc/nagios/conf.d/hosts.cfg'
  }

  Nagios_hostgroup {
    target => '/etc/nagios/conf.d/hostgroups.cfg'
  }

  Nagios_service {
    target => '/etc/nagios/conf.d/services.cfg',
  }

  define nagios::server::service (
    $command_name,
    $content,
    $hostgroup_name,
    $hostgroup_desc,
    $package_name = undef,
    $service_desc,
  ) {
    if (empty(nagios_hostgroups("${hostgroup_name}"))) {
      alert ('Undefined nagios-openstack service')
    }

    if ($package_name) {
      package { "$package_name":
        ensure => present
      }
    }

    nagios_hostgroup {"${hostgroup_name}":
      alias => "${hostgroup_desc}"
    }

    file {"/usr/lib64/nagios/plugins/${command_name}":
     mode    => 755,
     seltype => 'nagios_unconfined_plugin_exec_t',
     content => "${content}",
    }

    nagios_command {"${command_name}":
      command_line => "/usr/lib64/nagios/plugins/${command_name}",
    }

    nagios_service {"${command_name}":
      hostgroup_name        => "${hostgroup_name}",
      service_description   => "${service_desc}",
      check_command         => "${command_name}",
      normal_check_interval => '5',
      use                   => 'generic-service',
    }
  }

  file {'/etc/nagios/keystonerc_admin':
    ensure  => 'present',
    mode    => 600,
    content => template('nagios/keystonerc_admin.erb'),
  }

  # Nodes
  nagios_hostgroup {'openstack-node':
    alias => 'Openstack Node',
  }

  # Services
  nagios::server::service {'keystone':
    hostgroup_name => 'openstack-keystone',
    hostgroup_desc => 'OpenStack Keystone',
    package_name   => 'python-keystoneclient',
    command_name   => 'keystone-user-list',
    content        => template('nagios/keystone-user-list.erb'),
    service_desc   => 'Number of keystone users',
  }

  nagios::server::service {'nova-api':
    hostgroup_name => 'openstack-nova-api',
    hostgroup_desc => 'OpenStack Nova API',
    package_name   => 'python-novaclient',
    command_name   => 'nova-list',
    content        => template('nagios/nova-list.erb'),
    service_desc   => 'Number of nova instances',
  }

  nagios::server::service {'nova-compute':
    hostgroup_name => 'openstack-nova-compute',
    hostgroup_desc => 'OpenStack Nova Compute',
    command_name   => 'check_nrpe!virsh_nodeinfo',
    content        => '',
    service_desc   => 'Virsh nodeinfo',
  }

  nagios::server::service {'ceilometer-api':
    hostgroup_name => 'openstack-ceilometer-api',
    hostgroup_desc => 'OpenStack Ceilometer API',
    package_name   => 'python-ceilometerclient',
    command_name   => 'ceilometer-list',
    content        => template('nagios/ceilometer-list.erb'),
    service_desc   => 'Number of ceilometer objects',
  }

  nagios::server::service {'cinder-api':
    hostgroup_name => 'openstack-cinder-api',
    hostgroup_desc => 'OpenStack Cinder API',
    package_name   => 'python-cinderclient',
    command_name   => 'cinder-list',
    content        => template('nagios/cinder-list.erb'),
    service_desc   => 'Number of cinder volumes',
  }

  nagios::server::service {'glance-api':
    hostgroup_name => 'openstack-glance-api',
    hostgroup_desc => 'OpenStack Glance API',
    package_name   => 'python-glanceclient',
    command_name   => 'glance-list',
    content        => template('nagios/glance-list.erb'),
    service_desc   => 'Number of glance images',
  }

  nagios::server::service {'heat-api':
    hostgroup_name => 'openstack-heat-api',
    hostgroup_desc => 'OpenStack Heat API',
    package_name   => 'python-heatclient',
    command_name   => 'heat-list',
    content        => template('nagios/heat-list.erb'),
    service_desc   => 'Number of heat objects',
  }

  if str2bool("$neutron") {
    nagios::server::service {'neutron-server':
      hostgroup_name => 'neutron-server',
      hostgroup_desc => 'Neutron API',
      package_name   => 'python-neutronclient',
      command_name   => 'neutron-net-list',
      content        => template('nagios/neutron-net-list.erb'),
      service_desc   => 'Number of neutron networks',
    }

    nagios::server::service {'neutron-network-check':
      hostgroup_name => 'openstack-server',
      hostgroup_desc => 'OpenStack API',
      package_name   => 'python-neutronclient',
      command_name   => 'neutron-network-check',
      content        => template('nagios/neutron-network-check'),
      service_desc   => 'Neutron network check: Adds an instance, allocates a floating IP to it',
    }
  }

  if str2bool("$swift") {
    nagios::server::service {'swift-api':
      hostgroup_name => 'openstack-swift-api',
      hostgroup_desc => 'OpenStack Swift API',
      package_name   => 'python-swiftclient',
      command_name   => 'swift-list',
      content        => template('nagios/swift-list.erb'),
      service_desc   => 'Number of swift objects',
    }
  }

  if "${settings::storeconfigs_backend}" == 'puppetdb' {
    # Collect Opentsack hosts
    Nagios_host <<| |>>
  }
  else {
    create_resources(nagios_host, nagios_hosts_get(), { 'ensure' => present })
  }
}
