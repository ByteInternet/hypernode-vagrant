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
  describe "#fs_type" do

    context "when the user inputs an unknown fs type" do
      it "returns fs type unknown" do
	# check if the setting is prompted for and pretend it returns an "rsync" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_FS_TYPES, DEFAULT_FS_TYPE,
	  "What filesystem type do you want to use? Options: nfs_guest, nfs, rsync, virtualbox [default #{DEFAULT_FS_TYPE}]: "
	).and_return("unknown_fs_type")
        # check a message is printed about the fs type
        expect(ui).to receive(:info).once.with(/.*Unknown.*/)
	# check if the function returns the unknown fs type
        expect( subject.get_fs_type(env) ).to eq("unknown_fs_type")
      end
    end

    context "when the user inputs fs type rsync" do
      it "returns fs type rsync" do
	# check if the setting is prompted for and pretend it returns an "rsync" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_FS_TYPES, DEFAULT_FS_TYPE,
	  "What filesystem type do you want to use? Options: nfs_guest, nfs, rsync, virtualbox [default #{DEFAULT_FS_TYPE}]: "
	).and_return("rsync")
        # check a message is printed about the fs type
        expect(ui).to receive(:info).once.with(/.*rsync.*filesync.*/)
	# check if the function returns "rsync" 
        expect( subject.get_fs_type(env) ).to eq("rsync")
      end
    end

    context "when the user inputs fs type virtualbox" do
      it "returns fs type virtualbox" do
	# check if the setting is prompted for and pretend it returns a "virtualbox" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_FS_TYPES, DEFAULT_FS_TYPE,
	  "What filesystem type do you want to use? Options: nfs_guest, nfs, rsync, virtualbox [default #{DEFAULT_FS_TYPE}]: "
	).and_return("virtualbox")
        # check a message is printed about the fs type
        expect(ui).to receive(:info).once.with(/.*is the default.*/)
	# check if the function returns "virtualbox" 
        expect( subject.get_fs_type(env) ).to eq("virtualbox")
      end
    end

    context "when the user inputs fs type nfs_guest" do
      it "returns fs type nfs_guest" do
	# check if the setting is prompted for and pretend it returns an "nfs_guest" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_FS_TYPES, DEFAULT_FS_TYPE,
	  "What filesystem type do you want to use? Options: nfs_guest, nfs, rsync, virtualbox [default #{DEFAULT_FS_TYPE}]: "
	).and_return("nfs_guest")
        # check a message is printed about the fs type
        expect(ui).to receive(:info).once.with(/.*host will mount NFS.*/)
	# check if the function returns "nfs_guest" 
        expect( subject.get_fs_type(env) ).to eq("nfs_guest")
      end
    end

    context "when the user inputs fs type nfs" do
      it "returns fs type nfs" do
	# check if the setting is prompted for and pretend it returns an "nfs" answer
        expect(subject).to receive(:get_setting).with(
	  env, AVAILABLE_FS_TYPES, DEFAULT_FS_TYPE,
	  "What filesystem type do you want to use? Options: nfs_guest, nfs, rsync, virtualbox [default #{DEFAULT_FS_TYPE}]: "
	).and_return("nfs")
        # check a message is printed about the fs type
        expect(ui).to receive(:info).once.with(/.*guest will mount NFS.*/)
	# check if the function returns "nfs" 
        expect( subject.get_fs_type(env) ).to eq("nfs")
      end
    end
  end
end

