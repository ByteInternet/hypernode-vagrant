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
  let(:ui) do
    double('ui').tap do |ui|
      allow(ui).to receive(:info) { nil }
    end
  end

  # Call the method under test after every 'it'. Similar to setUp in Python TestCase
  after do
    subject.ensure_magento_mounts_configured(env)
  end

  # instantiate class of which a method is to be tested
  subject { described_class.new(app, env) }

  # the method that we are going to test
  describe "#ensure_magento_mounts_configured" do

    context "when magento version is 1 and there is a magento 2 mount" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" }
	  }
	}
      } }
      let(:expected_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => { },
          "disabled_folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" }
	  }
	}
      } }
      it "disables the magento 2 mount" do
	# pretend we retrieve the settings and they specify magent->version 1 and a magento 2 mount
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the magento 2 mount is disabled
        expect(ui).to receive(:info).once.with(/Disabling fs->folders->magento2.*/)
	# check if the magento 2 mount is disabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when magento version is 2 and there is a magento 1 mount" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 2 },
        "fs" => { 
          "folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      let(:expected_settings) { { 
        "magento" => { "version" => 2 },
        "fs" => { 
          "folders" => { },
          "disabled_folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      it "disables the magento 1 mount" do
	# pretend we retrieve the settings and they specify magent->version 2 and a magento 1 mount
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the magento 1 mount is disabled
        expect(ui).to receive(:info).once.with(/Disabling fs->folders->magento1.*/)
	# check if the magento 1 mount is disabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when magento version is 1 and there are mounts for both magento 1 and 2" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" },
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      let(:expected_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => { 
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  },
          "disabled_folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" }
	  }
	}
      } }
      it "disables the magento 2 mount but keeps the magento 1 mount enabled" do
	# pretend we retrieve the settings and they specify magent->version 1 and mounts for both magento 1 and 2
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the magento 2 mount is disabled
        expect(ui).to receive(:info).once.with(/Disabling fs->folders->magento2.*/)
	# check if the magento 2 mount is disabled but the magento 1 mount is still enabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when magento version is 2 and there are mounts for both magento 1 and 2" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 2 },
        "fs" => { 
          "folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" },
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      let(:expected_settings) { { 
        "magento" => { "version" => 2 },
        "fs" => { 
          "folders" => { 
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" }
	  },
          "disabled_folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      it "disables the magento 1 mount but keeps the magento 2 mount enabled" do
	# pretend we retrieve the settings and they specify magent->version 2 and mounts for both magento 1 and 2
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the magento 1 mount is disabled
        expect(ui).to receive(:info).once.with(/Disabling fs->folders->magento1.*/)
	# check if the magento 1 mount is disabled but the magento 2 mount is still enabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when magento version is whatever and there are no magento1 or magento2 mounts" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 1234 },
        "fs" => {
            "nginx" => { "host" => "data/web/nginx", "guest" => "/data/web/nginx" }
	 }
      } }
      it "does not change the settings" do
	# pretend we retrieve the settings and they specify a random magent->version and no mounts we should automatically enable/disable
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we don't notify the user
        expect(ui).to receive(:info).never.with(/Disabling.*/)
        expect(ui).to receive(:info).never.with(/Re-enabling.*/)
	# check if no settings were changed
        expect(subject).to receive(:update_settings).once.with(retrieved_settings)
      end
    end

    context "when magento version is 2 and there is a disabled magento 2 mount" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 2 },
        "fs" => { 
          "folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  },
          "disabled_folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" },
	  }
	}
      } }
      let(:expected_settings) { { 
        "magento" => { "version" => 2 },
        "fs" => { 
          "folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" },
	  },
          "disabled_folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      it "disables the magento 1 mount and re-enabled the magento 2 mount" do
	# pretend we retrieve the settings and they specify magent->version 2 and mounts for both magento 1 and 2
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the magento 1 mount is disabled
        expect(ui).to receive(:info).once.with(/Disabling fs->folders->magento1.*/)
	# check if we notify the user that the magento 2 mount is re-enabled
        expect(ui).to receive(:info).once.with(/Re-enabling fs->disabled_folders->magento2.*/)
	# check if the magento 1 mount is disabled and the magento 2 mount is re-enabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when magento version is 1 and there is a disabled magento 1 mount" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" },
	  },
          "disabled_folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      let(:expected_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  },
          "disabled_folders" => {
            "magento2" => { "host" => "data/web/magento2", "guest" => "/data/web/magento2" },
	  }
	}
      } }
      it "disables the magento 2 mount and re-enabled the magento 1 mount" do
	# pretend we retrieve the settings and they specify magent->version 1 and mounts for both magento 1 and 2
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the magento 2 mount is disabled
        expect(ui).to receive(:info).once.with(/Disabling fs->folders->magento2.*/)
	# check if we notify the user that the magento 1 mount is re-enabled
        expect(ui).to receive(:info).once.with(/Re-enabling fs->disabled_folders->magento1.*/)
	# check if the magento 2 mount is disabled and the magento 1 mount is re-enabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

    context "when no disabled folders settings has to be kept" do
      let(:retrieved_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => { },
          "disabled_folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      let(:expected_settings) { { 
        "magento" => { "version" => 1 },
        "fs" => { 
          "folders" => {
            "magento1" => { "host" => "data/web/public", "guest" => "/data/web/public" }
	  }
	}
      } }
      it "re-enables the magento 1 mount and removes the empty disabled_folders hash" do
	# pretend we retrieve the settings and they specify magent->version 1 and mounts for magento 1
        expect(subject).to receive(:retrieve_settings).once.with(no_args).and_return(retrieved_settings)
	# check if we notify the user that the magento 1 mount is re-enabled
        expect(ui).to receive(:info).once.with(/Re-enabling fs->disabled_folders->magento1.*/)
	# check if the disabled_folders hash is deleted and the magento 1 mount is re-enabled
        expect(subject).to receive(:update_settings).once.with(expected_settings)
      end
    end

  end
end

