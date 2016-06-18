# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'vagrant'
  
module VagrantHypconfigmgmt
  class Config < Vagrant.plugin("2", :config)
    attr_accessor :enabled

    def initialize
      super
      # UNSET_VALUE so that Vagrant can properly automatically merge multiple configurations.
      # https://www.vagrantup.com/docs/plugins/configuration.html
      @enabled = UNSET_VALUE
    end

    def finalize!
      @enabled = (@enabled != UNSET_VALUE) && (@enabled != false)
    end
  end
end
