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
  let(:ui) { }

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.ensure_setting_exists(setting_name)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_setting_exists" do

    context "when the passed setting does not exist" do
      let(:retrieved_settings) { { } } 
      let(:expected_settings) { { setting_name => { } } } 
      it "creates an empty hash for the setting and saves it back to disk" do
	# pretend we retrieve the settings and they don't contain a magento block
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we update the settings with an empty magento block
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when the passed setting already exists" do
      let(:retrieved_settings) { { setting_name => { } } }
      it "no settings are changed" do
	# pretend we retrieve the settings and they already contain a magento block
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we don't change the retrieved settings because the setting already existed
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end
  end
end

