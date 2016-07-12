# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require "vagrant"
require "vagrant-hypconfigmgmt/command"

module VagrantHypconfigmgmt
  class Plugin < Vagrant.plugin("2")
    name "hypconfigmgmt"
    description <<-DESC
    Configure the hypernode-vagrant during runtime
    DESC

    config 'hypconfigmgmt' do
      require File.expand_path("../vagrant-hypconfigmgmt/config", __FILE__)
      Config
    end

    action_hook(:VagrantHypconfigmgmt, :machine_action_up) do |hook|
      hook.prepend(VagrantHypconfigmgmt::Command)
    end
  end
end
