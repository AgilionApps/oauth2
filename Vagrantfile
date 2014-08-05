# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'hashicorp/precise64'

  config.vm.network :forwarded_port, guest: 4200, host: 4201
  config.vm.network :private_network, ip: '10.10.10.60'

  config.vm.synced_folder '.', '/vagrant', type: 'nfs'

  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--memory', '512']
  end

  config.vm.provision 'shell', path: 'https://raw.github.com/AgilionApps/VagrantDevEnv/master/scripts/base.sh'
  config.vm.provision 'shell', path: 'https://raw.github.com/AgilionApps/VagrantDevEnv/master/scripts/postgresql.sh'
  config.vm.provision 'shell', path: 'https://raw.github.com/AgilionApps/VagrantDevEnv/master/scripts/erlang.sh'
  config.vm.provision 'shell', privileged: false, path: 'https://raw.github.com/AgilionApps/VagrantDevEnv/master/scripts/elixir.sh'
end
