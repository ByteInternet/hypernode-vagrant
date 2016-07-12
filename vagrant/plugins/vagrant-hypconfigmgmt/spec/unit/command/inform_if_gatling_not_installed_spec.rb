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
    subject.inform_if_gatling_not_installed(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#inform_if_gatling_not_installed" do

    context "synced folder type is rsync gatling is not installed" do
      let(:retrieved_settings) { { "fs" => { "type" => "rsync" } } }
      it "notifies the user that it should install vagrant-gatling-rsync for a performance gain" do
	# check if settings are retrieved from disk and pretend they return a configuration for fs type rsync
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we test if the vagrant-gatling-rsync plugin is installed and pretend it is not
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-gatling-rsync").and_return(false)
	# check if a message is logged when the plugin is not installed
        expect(ui).to receive(:info).once.with(/.*vagrant plugin install vagrant-gatling-rsync*./)
      end
    end

    context "synced folder type is rsync gatling is installed" do
      let(:retrieved_settings) { { "fs" => { "type" => "rsync" } } }
      it "does not notify the user because vagrant-gatling-rsync is already installed" do
	# check if settings are retrieved from disk and pretend they return a configuration for fs type rsync
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we test if the vagrant-gatling-rsync plugin is installed and pretend it is
        expect(Vagrant).to receive(:has_plugin?).once.with("vagrant-gatling-rsync").and_return(true)
	# check if no message is logged because the plugin is already installed
        expect(ui).to receive(:info).never
      end
    end

    context "synced folder type is not rsync" do
      let(:retrieved_settings) { { "fs" => { "type" => "nfs_guest" } } }
      it "notifies the user that it should install vagrant-gatling-rsync for a performance gain" do
	# check if settings are retrieved from disk and pretend they return a configuration for fs type nfs_guest
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we don't test for the vagrant-gatling-rsync plugin because we are using a different fs type
        expect(Vagrant).to receive(:has_plugin?).never
	# check if no message is logged because we don't use the rsync fs type
        expect(ui).to receive(:info).never
      end
    end
  end
end

