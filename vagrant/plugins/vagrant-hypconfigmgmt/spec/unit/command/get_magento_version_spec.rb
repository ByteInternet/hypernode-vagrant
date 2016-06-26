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
  describe "#get_magento_version" do

    context "when magento 1 is configured" do
      it "it notifies the user about the /data/web/public webdir and returns the value" do
	# check if the setting is prompted for and pretend it returns a "magento 1" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_MAGENTO_VERSIONS, DEFAULT_MAGENTO_VERSION,
	  "Is this a Magento #{subject.get_options_string(AVAILABLE_MAGENTO_VERSIONS)} Hypernode? [default #{DEFAULT_MAGENTO_VERSION}]: "
	).and_return("1")
        # check if the user is notified about the correct webdir
        expect(ui).to receive(:info).once.with(/.*Magento 1*/)
	# check if the function returns int 1 if a Magento 1 Vagrant is to be used
        expect( subject.get_magento_version(env) ).to eq(1)
      end
    end


    context "when magento 2 is configured" do
      it "it notifies the user about the /data/web/magento2/pub symlink returns the value" do
	# check if the setting is prompted for and pretend it returns a "magento 2" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_MAGENTO_VERSIONS, DEFAULT_MAGENTO_VERSION,
	  "Is this a Magento #{subject.get_options_string(AVAILABLE_MAGENTO_VERSIONS)} Hypernode? [default #{DEFAULT_MAGENTO_VERSION}]: "
	).and_return("2")
        # check if the user is notified about the correct webdir
        expect(ui).to receive(:info).once.with(/.*Magento 2*/)
	# check if the function returns int 2 if a Magento 2 Vagrant is to be used
        expect( subject.get_magento_version(env) ).to eq(2)
      end
    end
  end
end


