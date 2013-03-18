require 'log4r'
require 'vagrant/util/retryable'
require 'vagrant-actionio/errors'

module VagrantPlugins
  module ActionIO
    module Action
      # This runs the configured instance.
      class StartInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_actionio::action::start_instance')
        end

        def call(env)
          @app.call(env)

          machine = env[:machine]
          actionio = env[:actionio]

          box_id = machine.id

          start_box(actionio, machine)

          # Poll server to check whether the box is ready
          env[:ui].info(I18n.t('vagrant_actionio.starting_box'))

          # Wait 10 seconds first
          sleep 10.0

          wait_for_box_to_start(env)

          env[:ui].info(I18n.t('vagrant_actionio.ready'))

          @app.call(env)
        end

        def start_box(actionio, machine)
          actionio.request(:put, "/boxes/#{machine.id}/start")
        end

        def wait_for_box_to_start(env)
          actionio = env[:actionio]
          machine = env[:machine]
          retryable(on: Errors::BoxNotYetStartedError, tries: 10, sleep: 5.0) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # check for the box's status
            if actionio.fetch_box_state(machine.id) != :running
              raise Errors::BoxNotYetStartedError
            end
          end
        end
      end
    end
  end
end
