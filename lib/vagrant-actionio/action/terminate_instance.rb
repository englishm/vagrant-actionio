require 'log4r'
require 'vagrant/util/retryable'
require 'vagrant-actionio/errors'

module VagrantPlugins
  module ActionIO
    module Action
      # This terminates the running instance.
      class TerminateInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_actionio::action::terminate_instance')
        end

        def call(env)
          actionio = env[:actionio]
          machine = env[:machine]

          # Destroy the server and remove the tracking ID
          env[:ui].info(I18n.t('vagrant_actionio.terminating_box'))
          terminate_box(actionio, machine)

          # Wait 15 seconds first
          sleep 15.0

          wait_for_box_to_terminate(env)

          machine.id = nil

          env[:ui].info(I18n.t('vagrant_actionio.terminated'))

          @app.call(env)
        end

        def terminate_box(actionio, machine)
          actionio.request(:delete, "/boxes/#{machine.id}")
        end

        def wait_for_box_to_terminate(env)
          actionio = env[:actionio]
          machine = env[:machine]
          retryable(on: Errors::BoxNotYetTerminatedError, tries: 10, sleep: 3.0) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # check for the box's status
            if actionio.fetch_box_state(machine.id) != :terminated
              raise Errors::BoxNotYetTerminatedError
            end
          end
        end
      end
    end
  end
end
