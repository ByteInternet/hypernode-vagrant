# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'yaml'
require 'spec_helper'
require "vagrant-hypconfigmgmt/command"


describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { }

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#retrieve_settings" do

    context "when the configuration file already exists" do
      let(:return_hash) { { "some" => "setting" } }
      it "loads the configuration file and returns the data" do
        expect(YAML).to receive(:load_file).once.with(H_V_SETTINGS_FILE).and_return(return_hash)
        expect(YAML).to receive(:load_file).never.with(H_V_BASE_SETTINGS_FILE)
        expect( subject.retrieve_settings() ).to eq(return_hash)
      end
    end

    context "when the configuration file still needs to be created" do
      let(:return_hash) { { "some" => "other_setting" } }
      it "loads the base configuration file and returns the data" do
        expect(YAML).to receive(:load_file).once.with(H_V_SETTINGS_FILE).and_raise(Errno::ENOENT)
        expect(YAML).to receive(:load_file).once.with(H_V_BASE_SETTINGS_FILE).and_return(return_hash)
        expect( subject.retrieve_settings() ).to eq(return_hash)
      end
    end
  end
end

