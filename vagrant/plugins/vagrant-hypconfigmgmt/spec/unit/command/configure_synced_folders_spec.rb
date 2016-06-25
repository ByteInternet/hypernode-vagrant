# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"

describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { }

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.configure_synced_folders(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#configure_synced_folders" do

    context "when env is passed" do
      it "configures all the settings for the synced folders" do
        # check the magento mounts are configured
        expect(subject).to receive(:ensure_magento_mounts_configured).with(env)
        # check the directory to be mounted is validated against the magento version (pub symlink vs public)
        expect(subject).to receive(:validate_magento2_root).with(env)
        # check a message will be printed if gatling is not installed while the rsync fs type is specified
        expect(subject).to receive(:inform_if_gatling_not_installed).with(env)
      end
    end
  end
end
