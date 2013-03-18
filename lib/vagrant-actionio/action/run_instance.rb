require 'log4r'
require 'vagrant/util/retryable'
require 'vagrant-actionio/util/timer'
require 'vagrant-actionio/errors'
require 'securerandom'

module VagrantPlugins
  module ActionIO
    module Action
      # This runs the configured instance.
      class RunInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_actionio::action::run_instance')
        end

        def call(env)
          # Initialize metrics if they haven't been
          env[:metrics] ||= {}
          @app.call(env)

          machine = env[:machine]
          actionio = env[:actionio]

          # Get the configs
          config = machine.provider_config
          box_name = "vagrant-#{SecureRandom.hex 5}"
          region = config.region
          stack = config.stack

          # Launch!
          env[:ui].info I18n.t('vagrant_actionio.launching_box')
          env[:ui].info " -- Box Name: #{box_name}"
          env[:ui].info " -- Region: #{region}"
          env[:ui].info " -- Stack: #{stack}"

          create_box(actionio, machine, box_name, region, stack)

          # Poll server to check whether the box is ready
          env[:ui].info(I18n.t('vagrant_actionio.starting_box'))

          # Wait 15 seconds first
          sleep 15.0

          wait_for_box_to_start(env)

          @logger.info("Time to instance ready: #{env[:metrics]["instance_ready_time"]}")

          if !env[:interrupted]
            # Ready and booted!
            env[:ui].info(I18n.t('vagrant_actionio.ready'))
          end

          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]

          @app.call(env)
        end

        def create_box(actionio, machine, box_name, region, stack)
          response = actionio.request(:post, '/boxes', params: { box: { name: box_name, region: region, box_template: stack } })

          # save box id
          machine.id = response.parsed['box']['id']
        end

        def wait_for_box_to_start(env)
          actionio = env[:actionio]
          machine = env[:machine]
          env[:metrics]['instance_ready_time'] = Util::Timer.time do
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
end
