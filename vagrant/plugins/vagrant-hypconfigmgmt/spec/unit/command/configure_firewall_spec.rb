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
    subject.configure_firewall(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#configure_firewall" do

    context "when env is passed" do
      it "configures the settings for firewall" do
	# check the firewall settings is ensured to exist in the configuration file
        expect(subject).to receive(:ensure_setting_exists).with('firewall')
	# check the firewall is disabled for incompatible fs types
	expect(subject).to receive(:ensure_firewall_disabled_for_incompatible_fs_types).with(env)
	# check the firewall state is ensured to be configured
	expect(subject).to receive(:ensure_attribute_configured).with(
          env, 'firewall', 'state', AVAILABLE_FIREWALL_STATES
	)
      end
    end
  end
end

