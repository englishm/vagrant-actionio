module VagrantPlugins
  module ActionIO
    module Action
      class MessageNotCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_actionio.not_created'))
          @app.call(env)
        end
      end
    end
  end
end
