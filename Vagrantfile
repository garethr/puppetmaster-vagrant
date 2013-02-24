# vi: set ft=ruby :
# -*- mode: ruby -*-

Vagrant::Config.run do |config|
  config.vm.box = "puppet-precise64"

  config.vm.define :server do |conf|
    conf.vm.network :hostonly, "10.0.0.20"
    conf.vm.forward_port 8080, 8080 # puppetdb web interface
    conf.vm.forward_port 8082, 8082 # puppetdb repl
    conf.vm.customize [
       "modifyvm", :id,
       "--memory", 2048,
       "--cpus", "2"
    ]
    conf.vm.host_name = "puppet"
    conf.vm.provision :puppet,
      :options => ["--debug", "--verbose", "--summarize"],
      :facter => { "fqdn" => "puppet" } do |puppet|
      puppet.manifests_path = "manifests"
      puppet.module_path    = "modules"
      puppet.manifest_file  = "server.pp"
    end
  end

  config.vm.define :client do |conf|
    conf.vm.network :hostonly, "10.0.0.21"
    conf.vm.host_name = "client"
    config.vm.provision :shell, :inline => "puppet resource host puppet ip='10.0.0.20'"
    config.vm.provision :puppet_server,
      :options => ["--debug", "--verbose", "--summarize", "--no-daemonize", "--onetime"] do |puppet|
      puppet.puppet_server = "puppet"
    end
  end
end
