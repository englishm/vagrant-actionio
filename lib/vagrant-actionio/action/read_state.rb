require 'log4r'
require 'vagrant-actionio/errors'

module VagrantPlugins
  module ActionIO
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_actionio::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:actionio], env[:machine])

          @app.call(env)
        end

        def read_state(actionio, machine)
          return :not_created if machine.id.nil?

          # Find the box
          state = actionio.fetch_box_state(machine.id)
          if state.nil?
            @logger.info("Box not found on Action.IO, assuming it got destroyed.")
            machine.id = nil
            return :not_created
          end
          state
        end
      end
    end
  end
end
