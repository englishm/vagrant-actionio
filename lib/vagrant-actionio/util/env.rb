module VagrantPlugins
  module ActionIO
    module Util
      class Env
        def self.read_with_default(env_var, default)
          value = ENV[env_var]
          value.nil? ? default : value
        end
      end
    end
  end
end
