module VagrantPlugins
  module ActionIO
    module Action
      class MessageCannotTerminate
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_actionio.cannot_terminate'))
          @app.call(env)
        end
      end
    end
  end
end
