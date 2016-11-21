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
    subject.configure_xdebug(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#configure_xdebug" do

    context "when env is passed" do
      it "configures the settings for xdebug" do
	# check the xdebug settings is ensured to exist in the configuration file
        expect(subject).to receive(:ensure_setting_exists).with('xdebug')
	# check the xdebug state is ensured to be configured
	expect(subject).to receive(:ensure_attribute_configured).with(
          env, 'xdebug', 'state', AVAILABLE_XDEBUG_STATES
	)
      end
    end
  end
end

