module VagrantPlugins
  module ActionIO
    module Action
      class MessageProvisioningNotYetSupported
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_actionio.provisioning_not_yet_supported'))
          @app.call(env)
        end
      end
    end
  end
end
