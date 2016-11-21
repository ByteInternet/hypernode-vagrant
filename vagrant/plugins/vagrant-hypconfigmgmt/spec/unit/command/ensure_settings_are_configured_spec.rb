# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"

describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { }

  # pretend we retrieve the original settings config from the filesystem
  let(:retrieve_settings_before) do
    double('retrieve_settings_before').tap do |retrieve_settings_before|
      allow(retrieve_settings_before).to receive(:to_yaml).with(no_args).and_return('before_settings')
    end
  end

  # pretend we retrieve the updated settings config from the filesystem
  let(:retrieve_settings_after) do
    double('retrieve_settings_after').tap do |retrieve_settings_after|
      allow(retrieve_settings_after).to receive(:to_yaml).with(no_args).and_return('after_settings')
    end
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_settings_configured" do

    context "when settings are updated" do
      it "configures all the settings and returns true" do
	# check retrieve_settings is called twice
        expect(subject).to receive(:retrieve_settings).twice.with(no_args).and_return(retrieve_settings_before, retrieve_settings_after)
	# check the magento settings are configured
        expect(subject).to receive(:configure_magento).with(env)
	# check the php settings are configured
        expect(subject).to receive(:configure_php).with(env)
	# check the varnish settings are configured
        expect(subject).to receive(:configure_varnish).with(env)
	# check the synced folder settings are configured
        expect(subject).to receive(:configure_synced_folders).with(env)
	# check the firewall settings are configured
        expect(subject).to receive(:configure_firewall).with(env)
	# check the memory management settings are configured
        expect(subject).to receive(:configure_cgroup).with(env)
	# check the Xdebug settings are configured
        expect(subject).to receive(:configure_xdebug).with(env)
	# check the vagrant settings are configured
        expect(subject).to receive(:configure_vagrant).with(env)
	# check true is returned when settings are updated
	expect( subject.ensure_settings_configured(env) ).to eq(true)
      end
    end

    context "when settings are not updated" do
      it "configures all the settings and returns false" do
	# check retrieve_settings is called twice
        expect(subject).to receive(:retrieve_settings).twice.with(no_args).and_return(retrieve_settings_before, retrieve_settings_before)
	# check the magento settings are configured
        expect(subject).to receive(:configure_magento).with(env)
	# check the php settings are configured
        expect(subject).to receive(:configure_php).with(env)
	# check the varnish settings are configured
        expect(subject).to receive(:configure_varnish).with(env)
	# check the synced folder settings are configured
        expect(subject).to receive(:configure_synced_folders).with(env)
	# check the firewall settings are configured
        expect(subject).to receive(:configure_firewall).with(env)
	# check the memory management settings are configured
        expect(subject).to receive(:configure_cgroup).with(env)
	# check the Xdebug settings are configured
        expect(subject).to receive(:configure_xdebug).with(env)
	# check the vagrant settings are configured
        expect(subject).to receive(:configure_vagrant).with(env)
	# check false is returned when settings are not updated
	expect( subject.ensure_settings_configured(env) ).to eq(false)
      end
    end
  end
end

