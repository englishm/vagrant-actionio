require "log4r"

module VagrantPlugins
  module ActionIO
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_actionio::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:actionio], env[:machine])

          @app.call(env)
        end

        def read_ssh_info(actionio, machine)
          return nil if machine.id.nil?

          # Find the box
          begin
            response = actionio.request(:get, "/boxes/#{machine.id}")
          rescue => e
            if e.respond_to?(:response) && e.response.status == 404
              # The machine can't be found
              @logger.info("Box not found on Action.IO, assuming it got destroyed.")
              machine.id = nil
              return nil
            else
              raise e
            end
          end

          box_info = response.parsed['box']

          # Get the configuration
          config = machine.provider_config

          # Read the info
          return {
            host: box_info['host'],
            port: box_info['port'].to_s,
            private_key_path: config.ssh_private_key_path,
            username: 'action'
          }
        end
      end
    end
  end
end
