require 'pathname'

require 'vagrant/action/builder'

module VagrantPlugins
  module ActionIO
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to terminate the remote machine.
      #def self.action_destroy
      #end

      # This action is called when `vagrant provision` is called.
      #def self.action_provision
      #end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      #def self.action_read_ssh_info
      #end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectActionIO
          b.use ReadState
        end
      end

      # This action is called to SSH into the machine.
      #def self.action_ssh
      #end

      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectActionIO

          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use MessageAlreadyCreated
              next
            end

            b2.use TimedProvision
            #b2.use SyncFolders
            b2.use WarnNetworks
            b2.use RunInstance
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :ConnectActionIO, action_root.join('connect_actionio')
      autoload :ReadState, action_root.join("read_state")
      autoload :IsCreated, action_root.join('is_created')
      autoload :MessageAlreadyCreated, action_root.join('message_already_created')
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :TimedProvision, action_root.join('timed_provision')
      #autoload :SyncFolders, action_root.join('sync_folders')
      autoload :WarnNetworks, action_root.join('warn_networks')
      autoload :RunInstance, action_root.join('run_instance')
    end
  end
end
