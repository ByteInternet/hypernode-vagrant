# -*- encoding: utf-8 -*-
# vim: set fileencoding=utf-8

require 'spec_helper'
require "vagrant-hypconfigmgmt/command"


describe VagrantHypconfigmgmt::Command do
  # create a fake app and env to pass into the VagrantHypconfigmgmt::Command constructor
  let(:app) { }
  let(:env) { { :ui => ui } }
  let(:setting_name) { get_random_string() }
  let(:attribute_name) { get_random_string() }
  let(:available) { [ ] }

  # pretend env contains the Vagrant ui element
  let(:ui) do
    double('ui').tap do |ui|
      allow(ui).to receive(:error) { nil }
    end
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_attribute_configured" do

    context "when the attribute is defined for and is valid" do
      let(:retrieved_settings) { { setting_name => { attribute_name => 'value2'} } } 
      it "does not print an error and does not update the setting" do
	# pretend we retrieve the settings and they contain a valid value
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if an error message is not printed
        expect(ui).to receive(:error).never
	# check if the settings are not changed because they are already correct
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
       
        # call the method with a code block (anonymous function) that is not executed because there
        # is already a correct value in the config: 'value2'
        subject.ensure_attribute_configured(
          env, setting_name, attribute_name, ['value1', 'value2']
        ) { | env | 'value1' }
      end
    end

    context "when the attribute is defined for the name but not in allowed value list" do
      let(:retrieved_settings) { { setting_name => { attribute_name => 'invalid_value'} } } 
      let(:expected_settings) { { setting_name => { attribute_name => 'value1' } } } 
      it "prints an error about the invalid value, defines the attribute and writes it back to disk" do
	# pretend we retrieve the settings and they contain an invalid value
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if an error message is printed
        expect(ui).to receive(:error).once.with(/.*#{setting_name}.*#{attribute_name}.*/)
	# check if the settings are updated with the yielded value passed as a block into the function
        expect(subject).to receive(:update_settings).once.with(expected_settings)
       
        subject.ensure_attribute_configured(
          env, setting_name, attribute_name, ['value1', 'value2']
        ) { | env | 'value1' }
      end
    end

    context "when the attribute is defined for the name but the allowed list has the value as an int" do
      let(:retrieved_settings) { { setting_name => { attribute_name => '1'} } } 
      it "does not update the setting because it is already valid" do
	# pretend we retrieve the settings and they contain a string value
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if no error message is printed
        expect(ui).to receive(:error).never
	# check if the settings are not updated
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
       
        subject.ensure_attribute_configured(
          env, setting_name, attribute_name, [1, 2]
        ) { | env | 2 }
      end
    end

    context "when the attribute is not defined for the name" do
      let(:retrieved_settings) { { setting_name => { } } } 
      let(:expected_settings) { { setting_name => { attribute_name => 'value1' } } } 
      it "defines the attribute and writes it back to disk" do
	# pretend we retrieve the settings and they do not contain the attribute already
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if no error message is printed
        expect(ui).to receive(:error).never
	# check if the settings are updated with the yielded value passed as a block into the function
        expect(subject).to receive(:update_settings).once.with(expected_settings)
       
        # a code block like "{ 'value1' }" is an anonymous function without a paramters 
        # like: "{ | | 'value1' }", (or "lambda: 'value1'" in python)
        subject.ensure_attribute_configured(
          env, setting_name, attribute_name, ['value1', 'value2']
        ) { 'value1' }
      end
    end
  end
end

