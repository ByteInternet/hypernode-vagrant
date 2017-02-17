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
    subject.configure_hostmanager(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#configure_hostmanager" do

    context "when env is passed" do
      it "configures the settings for the hostmanager" do
	# check the hostmanager settings is ensured to exist in the configuration file
        expect(subject).to receive(:ensure_setting_exists).with('hostmanager')
	# check the default domain is configured for the hostmanager
	expect(subject).to receive(:ensure_default_domain_configured).with(env)
      end
    end
  end
end

