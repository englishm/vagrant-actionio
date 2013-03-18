module VagrantPlugins
  module ActionIO
    module Action
      class MessageNotRunning
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_actionio.not_running'))
          @app.call(env)
        end
      end
    end
  end
end
