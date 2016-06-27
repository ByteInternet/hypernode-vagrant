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
      allow(ui).to receive(:error) { nil }
    end
  end

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.validate_magento2_root(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#validate_magento2_root" do

    context "when no fs is configured" do
      let(:retrieved_settings) { { "fs" => nil } } 
      it "does not print anything because there is no mount to go wrong" do
	# pretend we retrieve the settings and they don't specify a fs block
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if no info message is printed
        expect(ui).to receive(:info).never
	# check if no error message is printed
        expect(ui).to receive(:error).never
      end
    end

    context "when no folders are configured" do
      let(:retrieved_settings) { { "fs" => { "folders" => { } } } } 
      it "does not print anything because there is no folder to go wrong" do
	# pretend we retrieve the settings and they specify no folders to mount
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if no info message is printed
        expect(ui).to receive(:info).never
	# check if no error message is printed
        expect(ui).to receive(:error).never
      end
    end

    context "when folders are configured for magento 2 but magento version is 1" do
      let(:retrieved_settings) { { "magento" => { "version" => 1 }, "fs" => { "folders" => { 
        "magento2" => { "guest" => "/data/web/magento2" }, 
	"nginx" => { "guest" => "/data/web/public/someotherdir" }
      } } } }
      it "does not print anything because magento 2 mounts can coexist with a magento 1 configured box" do
	# pretend we retrieve the settings and they specify magento version 1and a synced folder with a magento 2 path
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if no info message is printed
        expect(ui).to receive(:info).never
	# check if no error message is printed
        expect(ui).to receive(:error).never
      end
    end

    context "when folders are configured for magento 1 and magento version is 1" do
      let(:retrieved_settings) { { "magento" => { "version" => 1 }, "fs" => { "folders" => { 
        "magento1" => { "guest" => "/data/web/public" }, 
	"nginx" => { "guest" => "/data/web/public/someotherdir" }
      } } } }
      it "does not print anything because magento 1 configured and only magento 1 mounts detected" do
	# pretend we retrieve the settings and they specify magento version 1 and a synced folder with a magento 1 path
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if no info message is printed
        expect(ui).to receive(:info).never
	# check if no error message is printed
        expect(ui).to receive(:error).never
      end
    end

    context "when folders are configured for magento 1 but magento version is 2" do
      let(:retrieved_settings) { { "magento" => { "version" => 2 }, "fs" => { "folders" => { 
        "magento1" => { "guest" => "/data/web/public/somedir" }, 
	"nginx" => { "guest" => "/data/web/public/someotherdir" }
      } } } }
      it "prints an error message because magento 2 mounts can't coexist with a magento 1 configured box because of the pub symlink" do
	# pretend we retrieve the settings and they specify magento version 2 and a synced folder with a magento 1 path
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if a message is printed that tells the user that the magento 2 dir structure can't be mounted on magento 1 configured boxes.
        expect(ui).to receive(:info).once.with(/Can not configure.*/)
	# check if an error message is printed that tells the user to remove /data/web/public mounts from the config
        expect(ui).to receive(:error).once.with(/Please remove all .*/)
      end
    end
  end
end

