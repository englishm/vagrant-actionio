require 'vagrant'

module VagrantPlugins
  module ActionIO
    module Errors
      class VagrantActionIOError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_actionio.errors')
      end

      class APIError < VagrantActionIOError
        error_key(:api_error)
      end

      class RsyncError < VagrantActionIOError
        error_key(:rsync_error)
      end
    end
  end
end
