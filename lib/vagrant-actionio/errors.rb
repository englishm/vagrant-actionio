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

      class BoxNotYetStartedError < VagrantActionIOError
        error_key(:box_not_yet_started_error)
      end

      class BoxNotYetStoppedError < VagrantActionIOError
        error_key(:box_not_yet_stopped_error)
      end

      class BoxNotYetTerminatedError < VagrantActionIOError
        error_key(:box_not_yet_terminated_error)
      end

      class RsyncError < VagrantActionIOError
        error_key(:rsync_error)
      end

      class TimeoutError < VagrantActionIOError
        error_key(:timeout_error)
      end
    end
  end
end
