require 'log4r'
require 'vagrant-actionio/connection'
require 'vagrant-actionio/errors'

module VagrantPlugins
  module ActionIO
    module Action
      # This action connects to ActionIO, verifies credentials work, and
      # puts the ActionIO connection object into the `:actionio` key
      # in the environment.
      class ConnectActionIO

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_actionio::action::connect_actionio')
        end

        def call(env)
          connection = Connection.new(env[:machine].provider_config.access_token)

          @logger.info('Verifying Access Token...')
          connection.verify_access_token

          env[:actionio] = connection

          @app.call(env)
        end
      end
    end
  end
end
