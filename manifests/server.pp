# Class for Nagios server
class nagios::server (
  $controller_ip,
  $neutron,
  $swift,
  $nagios_group   = 'nagios',
  $nagios_user    = 'nagios',
  $nagios_admin   = 'nagiosadmin',
  $nagios_admin_password,
  ) {

  Exec { timeout => 300 }

  File {
    owner => $nagios_user,
    group => $nagios_group,
  }

  package {['nagios', 'nagios-plugins-nrpe', 'nagios-plugins-ping']:
    ensure => present,
  }

  class {'nagios::server::config':
    admin_password => $nagios_admin_password,
    controller_ip  => $controller_ip,
    nagios_admin   => $nagios_admin,
    nagios_user    => $nagios_user,
    nagios_group   => $nagios_group,
    require        => Package['nagios'],
    notify         => Service['httpd'],

    neutron        => $neutron,
    swift          => $swift,
  }

  class {'apache':}
  class {'apache::mod::php':}
  class {'apache::mod::wsgi':}

  # The apache module purges files it doesn't know about
  # avoid this by referencing them here
  file {'/etc/httpd/conf.d/nagios.conf':}

  service {['nagios']:
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  firewall {'001 nagios incoming':
    proto    => 'tcp',
    dport    => ['80'],
    action   => 'accept',
  }
}
