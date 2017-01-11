require "vagrant"

module VagrantPlugins
  module VagrantInlinePlugin
    class Command
      def initialize(app, env)
        @app = app
        @env = env
      end

      def call(env)
        env[:machine].communicate.sudo(
          "ps -ef | grep -v \"grep\" | grep varnishd -q || (service varnish start && sleep 1)",
          {:error_check => false}
        ) do |type, data|
          output = data.to_s.strip()
          if output.include? "Starting HTTP accelerator varnishd"
            env[:ui].info("Started Varnish")
          end
        end
        @app.call(env)
      end
    end
  end

  class Plugin < Vagrant.plugin("2")
    name "Ensure varnish is started as soon as the instance is started"

    action_hook(:VagrantInlinePlugin) do |hook|
      hook.after(
        Vagrant::Action::Builtin::WaitForCommunicator, 
        VagrantInlinePlugin::Command
      )
    end
  end
end
