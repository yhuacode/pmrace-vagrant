# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure("2") do |config|
  ##### DEFINE VM #####
  config.vm.define "PMRace-AE" do |config|
    config.vm.provision :shell, path: "bootstrap.sh"
    config.vm.hostname = "PMRace-AE"
    config.vm.box = "generic/ubuntu1804"
    config.vm.box_check_update = false
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder "download/", "/home/vagrant/download"
    config.vm.synced_folder "scripts/", "/home/vagrant/scripts"
    config.vm.synced_folder "seeds/", "/home/vagrant/seeds"
    config.vm.provider :virtualbox do |v|
      v.memory = 32768
      v.cpus = 16
    end
  end
end
