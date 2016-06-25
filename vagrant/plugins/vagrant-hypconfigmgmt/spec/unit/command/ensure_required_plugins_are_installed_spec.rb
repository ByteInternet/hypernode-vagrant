# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"

describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { { :ui => ui } }

  # pretend env contains the Vagrant ui element
  let(:ui) do
    double('ui').tap do |ui|
      allow(ui).to receive(:info) { nil }
    end
  end

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.ensure_required_plugins_are_installed(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_required_plugins_are_installed" do

    context "when no plugins are installed" do
      it "installs the plugins" do
	# test if the vagrant-hostmanager plugin is checked for being installed on the system and pretend it isn't
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-hostmanager").and_return(false)
	# test if the vagrant-vbguest plugin is checked for being installed on the system it isn't
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-vbguest").and_return(false)
	# check if a message about installing the vagrant-hostmanager plugin is printed
        expect(ui).to receive(:info).once.with("Installing the vagrant-hostmanager plugin.")
	# check if a message about installing the vagrant-vbguest plugin is printed
        expect(ui).to receive(:info).once.with("Installing the vagrant-vbguest plugin.")
	# check if a system call is done to install the vagrant-hostmanager plugin in a different process
        expect(subject).to receive(:system).once.with("vagrant plugin install vagrant-hostmanager")
	# check if a system call is done to install the vagrant-vbguest plugin in a different process
        expect(subject).to receive(:system).once.with("vagrant plugin install vagrant-vbguest")
      end
    end

    context "when plugins are already installed" do
      it "does not install the plugins" do
	# test if the vagrant-hostmanager plugin is checked for being installed on the system and pretend it is
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-hostmanager").and_return(true)
	# test if the vagrant-vbguest plugin is checked for being installed on the system it is
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-vbguest").and_return(true)
	# check if no message is printed about installing a plugin
        expect(ui).to receive(:info).never
	# check if no system call is done to install a plugin
        expect(subject).to receive(:system).never
      end
    end

    context "when not all plugins are installed intall the missing ones" do
      it "does not install the plugins" do
	# test if the vagrant-hostmanager plugin is checked for being installed on the system and pretend it is
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-hostmanager").and_return(true)
	# test if the vagrant-vbguest plugin is checked for being installed on the system it isn't
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-vbguest").and_return(false)
	# check if no message is printed about installing the already installed plugin
        expect(ui).to receive(:info).never.with("Installing the vagrant-hostmanager plugin.")
	# check if no system call is done to install the already installed plugin
        expect(subject).to receive(:system).never.with("vagrant plugin install vagrant-hostmanager")
	# check if a message about installing the not yet installed plugin is printed
        expect(ui).to receive(:info).once.with("Installing the vagrant-vbguest plugin.")
	# check if a system call is done to install the not yet installed plugin in a different process
        expect(subject).to receive(:system).once.with("vagrant plugin install vagrant-vbguest")
      end
    end
  end
end
