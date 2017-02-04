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
    subject.ensure_default_domain_configured(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_default_domain_configured" do

    context "when a default domain is configured" do
      let(:retrieved_settings) { { "hostmanager" => { "default_domain" => "exaxmple.com" } } }
      it "does not change the retrieved settings" do
	# check if settings are retrieved from disk and pretend they return a configuration for domain configured
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the same data
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end

    context "when no default domain is configured" do
      let(:retrieved_settings) { { "hostmanager" => Hash.new } }
      it "sets the default domain to the default domain" do
	expected_settings = { 
          "hostmanager" => { 
	    "default_domain" => "hypernode.local"
	  }
	}
	# check if settings are retrieved from disk and pretend they return a configuration for domain not configured
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the default domain
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end
  end
end


