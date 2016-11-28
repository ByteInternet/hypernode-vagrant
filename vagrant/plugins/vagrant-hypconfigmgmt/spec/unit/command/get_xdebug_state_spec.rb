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
  describe "#get_xdebug_state" do
    expected_message = "Do you want to install Xdebug? Enter true or false [default false]: "

    context "when the state is enabled" do
      it "it notifies the user that it will be enabled and returns the value" do
	# check if the setting is prompted for and pretend it returns a "xdebug enabled" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_XDEBUG_STATES, DEFAULT_XDEBUG_STATE, expected_message
	).and_return("true")
        # check if the user is notified that the xdebug will be enabled
        expect(ui).to receive(:info).once.with(/.*enabled.*/)
	# check if the function returns true if the xdebug should be enabled
        expect( subject.get_xdebug_state(env) ).to eq(true)
      end
    end


    context "when the state is disabled" do
      it "it notifies the user that it will be disabled and returns the value" do
	# check if the setting is prompted for and pretend it returns a "xdebug disabled" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_XDEBUG_STATES, DEFAULT_XDEBUG_STATE, expected_message
	).and_return("false")
        # check if the user is notified that the xdebug will be disabled
        expect(ui).to receive(:info).once.with(/.*disabled.*/)
	# check if the function returns false if the xdebug should be disabled
        expect( subject.get_xdebug_state(env) ).to eq(false)
      end
    end
  end
end

