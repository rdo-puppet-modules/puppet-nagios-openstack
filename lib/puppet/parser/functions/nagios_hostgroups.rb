module Puppet::Parser::Functions

# Services declared here must also be defined in nagios::server::openstack
  supported = [
    'neutron-server',
    'openstack-ceilometer-alarm-evaluator',
    'openstack-ceilometer-alarm-notifier',
    'openstack-ceilometer-api',
    'openstack-ceilometer-central',
    'openstack-ceilometer-collector',
    'openstack-ceilometer-notification',
    'openstack-cinder-api',
    'openstack-cinder-scheduler',
    'openstack-cinder-volume',
    'openstack-glance-api',
    'openstack-glance-registry',
    'openstack-heat-api',
    'openstack-heat-engine',
    'openstack-keystone',
    'openstack-nova-api',
    'openstack-nova-cert',
    'openstack-nova-compute',
    'openstack-nova-conductor',
    'openstack-nova-consoleauth',
    'openstack-nova-novncproxy',
    'openstack-nova-scheduler',
    'openstack-swift-api',
    'openstack-swift-proxy']


  newfunction(:nagios_hostgroups, :type => :rvalue,
  :doc => "Returns provide list filtered out from unsupported services") do |args|
    # 'openstack-node' is default hostgroup for every node
    list = ['openstack-node']
    args[0].split(',').each { |service|
      list << service if supported.include?(service)
    }
    list.join(',')
  end
end
