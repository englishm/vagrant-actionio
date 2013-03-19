module VagrantPlugins
  module ActionIO
    module Action
      class MessageAlreadyTerminated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_actionio.already_terminated'))
          @app.call(env)
        end
      end
    end
  end
end
