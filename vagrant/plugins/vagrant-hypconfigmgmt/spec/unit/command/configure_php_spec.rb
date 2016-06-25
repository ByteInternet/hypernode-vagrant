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
    subject.configure_php(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#configure_php" do

    context "when env is passed" do
      it "configures the settings for php" do
	# check the php settings is ensured to exist in the configuration file
        expect(subject).to receive(:ensure_setting_exists).with('php')
	# check the php version is ensured to be configured
	expect(subject).to receive(:ensure_php_version_configured).with(env)
      end
    end
  end
end
