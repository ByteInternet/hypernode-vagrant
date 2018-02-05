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
  describe "#get_options_string" do
    context "when there is only one option" do
      it "return that options as a string" do
        expect( subject.get_options_string([true]) ).to eq("true")
      end
    end

    context "when the options are strings" do
      it "returns them separated by 'or'" do
        expect( subject.get_options_string(["yes", "no"]) ).to eq("yes or no")
      end
    end

    context "when the options are bools" do
      it "it casts the bools to strings and returns them separated by 'or'" do
        expect( subject.get_options_string([true, false]) ).to eq("true or false")
      end
    end

    context "when the options are floats" do
      it "it casts the floats to strings and returns them separated by 'or'" do
        expect( subject.get_options_string([5.5, 5.6, 7.0, 7.1]) ).to eq("5.5 or 5.6 or 7.0 or 7.1")
      end
    end

    context "when the options are ints" do
      it "it casts the ints to strings and returns them separated by 'or'" do
        expect( subject.get_options_string([1, 2, 3]) ).to eq("1 or 2 or 3")
      end
    end
  end
end

