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


  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ubuntu_version" do

    context "when the user inputs ubuntu version precise" do
      it "returns ubuntu version precise" do
	# check if the setting is prompted for and pretend it returns a "precise" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_UBUNTU_VERSIONS, DEFAULT_UBUNTU_VERSION,
	  "What Ubuntu version do you want to use? Options: xenial, precise (deprecated) [default #{DEFAULT_UBUNTU_VERSION}]: "
	).and_return("precise")
        # check a message is printed about the ubuntu version
        expect(ui).to receive(:info).once.with(/.*Precise.*deprecated.*/)
	# check if the function returns "precise" 
        expect( subject.get_ubuntu_version(env) ).to eq("precise")
      end
    end

    context "when the user inputs ubuntu version xenial" do
      it "returns ubuntu version xenial" do
	# check if the setting is prompted for and pretend it returns a "virtualbox" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_UBUNTU_VERSIONS, DEFAULT_UBUNTU_VERSION,
	  "What Ubuntu version do you want to use? Options: xenial, precise (deprecated) [default #{DEFAULT_UBUNTU_VERSION}]: "
	).and_return("xenial")
        # check a message is printed about the ubuntu version
        expect(ui).to receive(:info).once.with(/.*Xenial.*default.*/)
	# check if the function returns "xenial" 
        expect( subject.get_ubuntu_version(env) ).to eq("xenial")
      end
    end
  end
end

