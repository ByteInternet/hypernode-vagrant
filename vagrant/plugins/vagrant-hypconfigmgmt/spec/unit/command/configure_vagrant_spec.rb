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
    subject.configure_vagrant(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#configure_vagrant" do

    context "when env is passed" do
      it "configures the settings for vagrant" do
	# check the vagrant settings is ensured to exist in the configuration file
        expect(subject).to receive(:ensure_setting_exists).with('vagrant')
	# check the vagrant box type is set to the right box for the pPHP version
	expect(subject).to receive(:ensure_vagrant_box_type_configured).with(env)
      end
    end
  end
end

