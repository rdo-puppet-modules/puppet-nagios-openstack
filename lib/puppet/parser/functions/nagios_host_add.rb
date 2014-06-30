require 'yaml'

module Puppet::Parser::Functions
  newfunction(:nagios_host_add, :type => :rvalue, :doc => "") do |args|
    # To do - Use puppet variables
    hosts_dir='/var/lib/puppet/server_data/nagios/hosts'

    if Dir[hosts_dir].empty?
      system("mkdir -p #{hosts_dir}")
    end

    File.open("#{hosts_dir}/#{args[0]}", 'w+') do |line|
      line << YAML.dump(args[1])
    end
  end
end
