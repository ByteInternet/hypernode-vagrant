# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"


describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { { :ui => ui } }
  let(:setting_name) { get_random_string() }

  # pretend env contains the Vagrant ui element
  let(:ui) do
    double('ui').tap do |ui|
      allow(ui).to receive(:info) { nil }
    end
  end

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.ensure_firewall_disabled_for_incompatible_fs_types(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_firewall_disabled_for_incompatible_fs_types" do
    context "when current fs type is compatible with the firewall and the firewall state was already defined" do
      let(:retrieved_settings) { { "fs" => { "type" => "virtualbox" }, "firewall" => { "state" => true } } }
      it "leaves the firewall enabled" do
        # pretend the settings are retrieved from disk and return a fs type that does not clash with the firewall
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we do not notify the user that the firewall will be disabled
        expect(ui).to receive(:info).never.with(/Disabling the firewall.*/)
	# check if the firewall is still enabled
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end

    context "when current fs type is compatible with the firewall and the firewall state was not yet defined" do
      let(:retrieved_settings) { { "fs" => { "type" => "virtualbox" }, "firewall" => { } } }
      it "does not changes the settings" do
        # pretend the settings are retrieved from disk and return a fs type that does not clash with the firewall
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we do not notify the user that the firewall will be disabled
        expect(ui).to receive(:info).never.with(/Disabling the firewall.*/)
	# check if the settings are not changed
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end

    context "when current fs type is not compatible with the firewall and the firewall state was already defined" do
      let(:retrieved_settings) { { "fs" => { "type" => "nfs_guest" }, "firewall" => { "state" => true } } }
      let(:expected_settings) { { "fs" => { "type" => "nfs_guest" }, "firewall" => { "state" => false } } }
      it "changes the existing firewall state to disabled" do
        # pretend the settings are retrieved from disk and return an incompatible fs type
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the firewall will be disabled
        expect(ui).to receive(:info).once.with(/Disabling the firewall.*/)
	# check if the firewall is disabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when current fs type is not compatible with the firewall and the firewall state was not defined" do
      let(:retrieved_settings) { { "fs" => { "type" => "nfs_guest" }, "firewall" => { }  } }
      let(:expected_settings) { { "fs" => { "type" => "nfs_guest" }, "firewall" => { "state" => false }  } }
      it "creates a new firewall state disabled" do
        # pretend the settings are retrieved from disk and return an incompatible fs type
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the firewall will be disabled
        expect(ui).to receive(:info).once.with(/Disabling the firewall.*/)
	# check if the firewall is disabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end
  end
end
