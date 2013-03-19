require 'log4r'
require 'vagrant/util/retryable'
require 'vagrant-actionio/errors'

module VagrantPlugins
  module ActionIO
    module Action
      # This runs the configured instance.
      class StopInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_actionio::action::stop_instance')
        end

        def call(env)
          actionio = env[:actionio]
          machine = env[:machine]

          stop_box(actionio, machine)

          # Poll server to check whether the box is ready
          env[:ui].info(I18n.t('vagrant_actionio.stopping_box'))

          # Wait 10 seconds first
          sleep 10.0

          wait_for_box_to_stop(env)

          env[:ui].info(I18n.t('vagrant_actionio.stopped'))

          @app.call(env)
        end

        def stop_box(actionio, machine)
          actionio.request(:put, "/boxes/#{machine.id}/stop")
        end

        def wait_for_box_to_stop(env)
          actionio = env[:actionio]
          machine = env[:machine]
          retryable(on: Errors::BoxNotYetStoppedError, tries: 10, sleep: 3.0) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # check for the box's status
            if actionio.fetch_box_state(machine.id) != :stopped
              raise Errors::BoxNotYetStoppedError
            end
          end
        end
      end
    end
  end
end
