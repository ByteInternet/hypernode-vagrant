# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"

describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { lambda { |env| } }
  let(:env) { { :machine => machine,  :ui => ui } }

  # pretend env contains the Vagrant ui element
  let(:ui) do
    double('ui').tap do |ui|
      allow(ui).to receive(:info) { nil }
    end
  end

  # pretend env[:machine].config.hypconfigmgmt.enabled is false
  let(:machine) do
    double('machine').tap do |machine|
      allow(machine).to receive(:config) { config }
    end
  end
  let(:config) do
    double('config').tap do |config|
      allow(config).to receive(:hypconfigmgmt) { hypconfigmgmt }
    end
  end
  let(:hypconfigmgmt) do
    double('hypconfigmgmt').tap do |config|
      allow(config).to receive(:enabled) { enabled }
    end
  end
  let(:enabled) { false }


  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.call(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#call" do

    context "when config hypconfigmgmt disabled (default)" do
      it "does nothing but call the super" do
        # check ensure_settings_configured is not called when plugin is disabled
        expect(subject).to receive(:ensure_settings_configured).never
        # check ensure_required_plugins_are_installed is not called when plugin is disabled
        expect(subject).to receive(:ensure_required_plugins_are_installed).never
        # check super is still called when plugin is disabled
        expect(app).to receive(:call).with(env)
      end
    end

    context "when config hypconfigmgmt enabled and no settings changed" do
      # pretend env[:machine].config.hypconfigmgmt.enabled is true
      let(:enabled) { true }

      it "ensures settings configured" do
        # check ensure_settings_configured is called when plugin is enabled
        expect(subject).to receive(:ensure_settings_configured).with(env).and_return(false)  # no changed settings
        # check ensure_required_plugins_are_installed is called when plugin is enabled
        expect(subject).to receive(:ensure_required_plugins_are_installed).with(env).and_return(nil)
	# check if we do not print the "please run vagrant up again" notice
        expect(ui).to receive(:info).never.with("Your hypernode-vagrant is now configured. Please run \"vagrant up\" again.")
        # check super is also called when plugin is enabled
        expect(app).to receive(:call).with(env)
      end
    end

    context "when config hypconfigmgmt enabled and settings changed" do
      # pretend env[:machine].config.hypconfigmgmt.enabled is true
      let(:enabled) { true }

      it "ensures settings configured" do
        # check ensure_settings_configured is called when plugin is enabled
        expect(subject).to receive(:ensure_settings_configured).with(env).and_return(true)  # changed settings
        # check ensure_required_plugins_are_installed is called when plugin is enabled
        expect(subject).to receive(:ensure_required_plugins_are_installed).with(env).and_return(nil)
	# check if we print the "please run vagrant up again" notice
        expect(ui).to receive(:info).once.with("Your hypernode-vagrant is now configured. Please run \"vagrant up\" again.")
        # interrupt the super call to make the user run 'vagrant up' again so changed settings take effect
        expect(app).to receive(:call).never
      end
    end
  end
end

