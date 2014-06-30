# Nagios server configuration
class nagios::server::config(
  $admin_password,
  $controller_ip,
  $nagios_admin,
  $nagios_group,
  $nagios_user,
  $neutron,
  $swift,
) {

  class { 'nagios::server::base':
    admin_password => $admin_password,
    nagios_admin   => $nagios_admin,
    nagios_user    => $nagios_user,
    nagios_group   => $nagios_group,
    require        => Package['nagios'],
  }

  class { 'nagios::server::nrpe':
    require => Class['nagios::server::base'],
    before  => Service['nagios'],
  }

  class { 'nagios::server::openstack':
    admin_password => $admin_password,
    controller_ip  => $controller_ip,
    nagios_user    => $nagios_user,
    nagios_group   => $nagios_group,
    neutron        => $neutron,
    swift          => $swift,
    require        => Class['nagios::server::base'],
    before         => Service['nagios'],
  }
}
