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

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.ensure_vagrant_box_type_configured(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_vagrant_box_type_configured" do

    context "when php 7.0 is configured" do
      let(:retrieved_settings) { { "php" => { "version" => 7.0 }, "vagrant" => Hash.new } }
      it "sets the box name and box url to the right values for PHP 7.0" do
	expected_settings = { 
          "php" => { 
	    "version" => 7.0
	  }, 
	  "vagrant" => { 
	    "box" => "hypernode_php7", 
	    "box_url" => "http://vagrant.hypernode.com/customer/php7/catalog.json" 
	  } 
	}
	# check if settings are retrieved from disk and pretend they return a configuration for php 7.0
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the right box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when php 7.0 is configured and precise ubuntu version specified" do
      let(:retrieved_settings) { { "php" => { "version" => 7.0 }, "vagrant" => Hash.new, "ubuntu_version" => "precise" } }
      it "sets the box name and box url to the right values for PHP 7.0" do
	expected_settings = { 
          "ubuntu_version" => "precise",
          "php" => { 
	    "version" => 7.0
	  }, 
	  "vagrant" => { 
	    "box" => "hypernode_php7", 
	    "box_url" => "http://vagrant.hypernode.com/customer/php7/catalog.json" 
	  } 
	}
	# check if settings are retrieved from disk and pretend they return a configuration for php 7.0
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the right box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when php 7.0 is configured and xenial ubuntu version specified" do
      let(:retrieved_settings) { { "php" => { "version" => 7.0 }, "vagrant" => Hash.new, "ubuntu_version" => "xenial" } }
      it "sets the box name and box url to the right values for PHP 7.0" do
	expected_settings = { 
          "ubuntu_version" => "xenial",
          "php" => { 
	    "version" => 7.0
	  }, 
	  "vagrant" => { 
	    "box" => "hypernode", 
	    "box_url" => "http://vagrant.hypernode.com/customer/xenial/catalog.json" 
	  } 
	}
	# check if settings are retrieved from disk and pretend they return a configuration for php 7.0
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the right box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when php 5.5 is configured" do
      let(:retrieved_settings) { { "php" => { "version" => 5.5 }, "vagrant" => Hash.new } }
      it "sets the box name and box url to the right values for PHP 5.5" do
	expected_settings = { 
          "php" => { 
	    "version" => 5.5 
	  }, 
	  "vagrant" => { 
	    "box" => "hypernode_php5", 
	    "box_url" => "http://vagrant.hypernode.com/customer/php5/catalog.json" 
	  } 
	}
	# check if settings are retrieved from disk and pretend they return a configuration for php 5.5
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the right box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when php 5.5 is configured and precise ubuntu version specified" do
      let(:retrieved_settings) { { "php" => { "version" => 5.5 }, "vagrant" => Hash.new, "ubuntu_version" => "precise" } }
      it "sets the box name and box url to the right values for PHP 5.5" do
	expected_settings = { 
          "ubuntu_version" => "precise",
          "php" => { 
	    "version" => 5.5 
	  }, 
	  "vagrant" => { 
	    "box" => "hypernode_php5", 
	    "box_url" => "http://vagrant.hypernode.com/customer/php5/catalog.json" 
	  } 
	}
	# check if settings are retrieved from disk and pretend they return a configuration for php 5.5
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the right box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when php 5.5 is configured and xenial ubuntu version specified" do
      let(:retrieved_settings) { { "php" => { "version" => 5.5 }, "vagrant" => Hash.new, "ubuntu_version" => "xenial" } }
      it "sets the box name and box url to the right values for PHP 5.5" do
	expected_settings = { 
          "ubuntu_version" => "xenial",
          "php" => { 
	    "version" => 5.5 
	  }, 
	  "vagrant" => { 
	    "box" => "hypernode", 
	    "box_url" => "http://vagrant.hypernode.com/customer/xenial/catalog.json" 
	  } 
	}
	# check if settings are retrieved from disk and pretend they return a configuration for php 5.5
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings that are written back to disk contain the right box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when an unknown php version is configured" do
      let(:retrieved_settings) { { "php" => { "version" => 1.0 }, "vagrant" => Hash.new } }
      it "does not set the box name and box url" do
	# check if settings are retrieved from disk and pretend they return an invalid php version
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings we write back to disk have an unaltered box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end

    context "when an unknown php version is configured and xenial ubuntu vreesion specified" do
      let(:retrieved_settings) { { "php" => { "version" => 1.0 }, "vagrant" => Hash.new, "ubuntu_version" => "xenial" } }
      it "does not set the box name and box url" do
	# check if settings are retrieved from disk and pretend they return an invalid php version
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if the settings we write back to disk have an unaltered box (name) and box_url
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end
  end
end


