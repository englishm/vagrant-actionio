module VagrantPlugins
  module ActionIO
    module Action
      class MessageAlreadyCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_actionio.already_created'))
          @app.call(env)
        end
      end
    end
  end
end
