# -*- coding: utf-8 -*-
# vagrant up --provider libvirt
BOX_IMAGE = "fedora/25-atomic-host"
NODE_COUNT = 2

SCRIPT = "sed -i -e 's|^Defaults.*secure_path.*$|Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin|g' /etc/sudoers"

Vagrant.configure("2") do |config|
  config.vm.define "master" do |subconfig|
    subconfig.vm.hostname = "master"
    subconfig.vm.network :private_network, ip: "10.0.0.10"
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "node#{i}" do |subconfig|
      subconfig.vm.hostname = "node#{i}"
      subconfig.vm.network :private_network, ip: "10.0.0.#{10 + i}"
    end
  end

  config.vm.synced_folder "/tmp", "/vagrant", disabled: 'true'
  config.vm.provision :shell, :inline  => SCRIPT
  config.vm.box = BOX_IMAGE

  config.vm.provider "libvirt" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  config.vm.provision "shell" do |s|
    ssh_pub_key = File.readlines(ENV['HOME'] + "/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      mkdir -p /home/vagrant/.ssh /root/.ssh
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
      lvextend -L10G /dev/atomicos/root
      xfs_growfs -d /dev/mapper/atomicos-root
    SHELL
  end
end
