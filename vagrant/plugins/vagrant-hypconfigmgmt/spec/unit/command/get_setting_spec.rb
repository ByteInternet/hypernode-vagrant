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
      allow(ui).to receive(:error) { nil }
      allow(ui).to receive(:ask) { input }
    end
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#get_setting" do

    context "value is not valid" do
      let(:input) { 'not_valid_input' }
      it "tries to get the setting again" do
        # check if the user is prompted for the setting
        expect(ui).to receive(:ask).twice.with("the ask message")
	# check if we get the default if the input is empty and pretend the input was returned
        expect(subject).to receive(:use_default_if_input_empty).with('not_valid_input', 2).and_return('not_valid', 2)
	# check the error message is printed because the input is not valid
        expect(ui).to receive(:error).once.with(/.*not a valid value.*/)
	# check if the re-prompted for setting is returned
	expect( subject.get_setting(env, [1, 2, 3], 2, "the ask message") ).to eq(2)
      end
    end

    context "value is valid" do
      let(:input) { '1' }
      it "does not try to get the setting again" do
        # check if the user is prompted for the setting
        expect(ui).to receive(:ask).once.with("the ask message")
	# check if we get the default if the input is empty and pretend the input was returned
        expect(subject).to receive(:use_default_if_input_empty).with('1', 1).and_return('1')
	# check we do not print an error message
        expect(ui).to receive(:error).never
	# check if the setting is returned
	expect( subject.get_setting(env, [1, 2, 3], 1, "the ask message") ).to eq('1')
      end
    end
  end
end

