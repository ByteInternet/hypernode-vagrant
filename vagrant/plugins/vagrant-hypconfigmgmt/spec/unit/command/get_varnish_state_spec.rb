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
  describe "#get_varnish_state" do

    context "when the state is enabled" do
      it "it notifies the user that it will be enabled and returns the value" do
	# check if the setting is prompted for and pretend it returns a "varnish enabled" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_VARNISH_STATES, DEFAULT_VARNISH_STATE,
	  "Do you want to enable Varnish? Enter true or false [default false]: "
	).and_return("true")
        # check if the user is notified that Varnish will be enabled
        expect(ui).to receive(:info).once.with(/.*enabled.*/)
	# check if the function returns true if Varnish should be enabled
        expect( subject.get_varnish_state(env) ).to eq(true)
      end
    end


    context "when the state is disabled" do
      it "it notifies the user that it will be disabled and returns the value" do
	# check if the setting is prompted for and pretend it returns a "varnish disabled" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_VARNISH_STATES, DEFAULT_VARNISH_STATE,
	  "Do you want to enable Varnish? Enter true or false [default false]: "
	).and_return("false")
        # check if the user is notified that Varnish will be disabled
        expect(ui).to receive(:info).once.with(/.*disabled.*/)
	# check if the function returns false if Varnish should be disabled
        expect( subject.get_varnish_state(env) ).to eq(false)
      end
    end
  end
end

