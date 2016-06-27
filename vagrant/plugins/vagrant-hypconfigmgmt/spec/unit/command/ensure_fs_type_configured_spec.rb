# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"

describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { }

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.ensure_fs_type_configured(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_fs_type_configured" do
    context "fs type is configured" do
      let(:retrieved_settings) { { "fs" => { "type" => "virtualbox"} } }
      it "configures the fs type" do
	# pretend we retrieve the settings and they specify no fs type
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the fs type is not gotten because we already have it specified in the settings
	expect(subject).to receive(:get_fs_type).never
	# check if the settings are unchanged
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end

    context "fs type is not configured" do
      let(:retrieved_settings) { { "fs" => { } } }
      let(:expected_settings) { { "fs" => { "type" => "rsync" }} }
      it "configures the fs type" do
	# pretend we retrieve the settings and they specify no fs type
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the fs type is gotten and pretend it returns rsync
	expect(subject).to receive(:get_fs_type).once.with(env).and_return('rsync')
	# check if the settings that are written back to disk contain the new fs type
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end
  end
end
