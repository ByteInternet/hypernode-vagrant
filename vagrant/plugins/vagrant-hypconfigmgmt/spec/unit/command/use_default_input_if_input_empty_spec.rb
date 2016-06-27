# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"

describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { }

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#use_default_if_input_empty" do
    context "when the input is empty (user pressed enter)" do
      it "it returns the default as string" do
        expect( subject.use_default_if_input_empty("", 1) ).to eq("1")
      end
    end

    context "when the input is not empty (user entered a value)" do
      it "it returns the input" do
        expect( subject.use_default_if_input_empty("2", 2) ).to eq("2")
      end
    end
  end
end

