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
  describe "#get_php_version" do

    context "when PHP 5.5 is configured" do
      it "it notifies the user that PHP 5.5 will be used and returns the value" do
        # check if the setting is prompted for and pretend it returns a "PHP 5.5" answer
        expect(subject).to receive(:get_setting).with(
          env, AVAILABLE_PHP_VERSIONS, DEFAULT_PHP_VERSION,
          "Is this a PHP #{subject.get_options_string(AVAILABLE_PHP_VERSIONS)} Hypernode? [default #{DEFAULT_PHP_VERSION}]: "
        ).and_return("5.5")
        # check if the user is notified about the PHP version
        expect(ui).to receive(:info).once.with(/.*PHP 5.5*/)
        # check if the function returns float 5.5 if a PHP 5.5 Vagrant is to be used
        expect( subject.get_php_version(env) ).to eq(5.5)
      end
    end


    context "when PHP 5.6 is configured" do
      it "it notifies the user that PHP 5.6 will be used and returns the value" do
        # check if the setting is prompted for and pretend it returns a "PHP 5.6" answer
        expect(subject).to receive(:get_setting).with(
          env, AVAILABLE_PHP_VERSIONS, DEFAULT_PHP_VERSION,
          "Is this a PHP #{subject.get_options_string(AVAILABLE_PHP_VERSIONS)} Hypernode? [default #{DEFAULT_PHP_VERSION}]: "
        ).and_return("5.6")
        # check if the user is notified about the PHP version
        expect(ui).to receive(:info).once.with(/.*PHP 5.6*/)
        # check if the function returns float 5.5 if a PHP 5.5 Vagrant is to be used
        expect( subject.get_php_version(env) ).to eq(5.6)
      end
    end


    context "when PHP 7.0 is configured" do
      it "it notifies the user that PHP 7.0 will be used and returns the value" do
        # check if the setting is prompted for and pretend it returns a "PHP 7.0" answer
        expect(subject).to receive(:get_setting).with(
          env, AVAILABLE_PHP_VERSIONS, DEFAULT_PHP_VERSION,
          "Is this a PHP #{subject.get_options_string(AVAILABLE_PHP_VERSIONS)} Hypernode? [default #{DEFAULT_PHP_VERSION}]: "
        ).and_return("7.0")
        # check if the user is notified about the PHP version
        expect(ui).to receive(:info).once.with(/.*PHP 7.0*/)
        # check if the function returns float 7.0 if a PHP 7.0 Vagrant is to be used
        expect( subject.get_php_version(env) ).to eq(7.0)
      end
    end


    context "when PHP 7.1 is configured" do
      it "it notifies the user that PHP 7.1 will be used and returns the value" do
        # check if the setting is prompted for and pretend it returns a "PHP 7.1" answer
        expect(subject).to receive(:get_setting).with(
          env, AVAILABLE_PHP_VERSIONS, DEFAULT_PHP_VERSION,
          "Is this a PHP #{subject.get_options_string(AVAILABLE_PHP_VERSIONS)} Hypernode? [default #{DEFAULT_PHP_VERSION}]: "
        ).and_return("7.1")
        # check if the user is notified about the PHP version
        expect(ui).to receive(:info).once.with(/.*PHP 7.1*/)
        # check if the function returns float 7.1 if a PHP 7.1 Vagrant is to be used
        expect( subject.get_php_version(env) ).to eq(7.1)
      end
    end


    context "when PHP 7.2 is configured" do
      it "it notifies the user that PHP 7.2 will be used and returns the value" do
        # check if the setting is prompted for and pretend it returns a "PHP 7.2" answer
        expect(subject).to receive(:get_setting).with(
          env, AVAILABLE_PHP_VERSIONS, DEFAULT_PHP_VERSION,
          "Is this a PHP #{subject.get_options_string(AVAILABLE_PHP_VERSIONS)} Hypernode? [default #{DEFAULT_PHP_VERSION}]: "
        ).and_return("7.2")
        # check if the user is notified about the PHP version
        expect(ui).to receive(:info).once.with(/.*PHP 7.2*/)
        # check if the function returns float 7.2 if a PHP 7.2 Vagrant is to be used
        expect( subject.get_php_version(env) ).to eq(7.2)
      end
    end
  end
end

