module VagrantPlugins
  module ActionIO
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is terminated and branch in the middleware.
      class IsTerminated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = [:terminated, :terminating].include?(env[:machine].state.id)
          @app.call(env)
        end
      end
    end
  end
end
