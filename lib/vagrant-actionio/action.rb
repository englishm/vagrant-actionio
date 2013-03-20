require 'pathname'

require 'vagrant/action/builder'

module VagrantPlugins
  module ActionIO
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to terminate the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectActionIO
          b.use Call, IsTerminated do |env, b2|
            if env[:result]
              b2.use MessageAlreadyTerminated
              b2.use RemoveMachineId
              next
            end

            b2.use Call, IsRunning do |env, b3|
              if env[:result]
                b3.use StopInstance
              end

              b3.use Call, IsStopped do |env, b4|
                if !env[:result]
                  b4.use MessageCannotTerminate
                  next
                end
                b4.use TerminateInstance
              end
            end
          end
        end
      end

      # This action is called when `vagrant provision` is called.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use MessageProvisioningNotYetSupported
          #b.use ConfigValidate
          #b.use Call, IsCreated do |env, b2|
            #if !env[:result]
              #b2.use MessageNotCreated
              #next
            #end

            #b2.use Provision
            #b2.use SyncFolders
          #end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectActionIO
          b.use ReadSSHInfo
        end
      end

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
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, IsRunning do |env, b3|
              if !env[:result]
                b3.use MessageNotRunning
                next
              end

              b3.use SSHExec
            end
          end
        end
      end

      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectActionIO

          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use MessageAlreadyCreated
              b2.use Call, IsStopped do |env, b3|
                if env[:result]
                  b3.use StartInstance
                end
              end
              next
            end

            #b2.use TimedProvision
            b2.use SyncFolders
            b2.use WarnNetworks
            b2.use RunInstance
            b2.use MessageProvisioningNotYetSupported
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :ConnectActionIO,          action_root.join('connect_actionio')
      autoload :IsCreated,                action_root.join('is_created')
      autoload :IsRunning,                action_root.join('is_running')
      autoload :IsStopped,                action_root.join('is_stopped')
      autoload :IsTerminated,             action_root.join('is_terminated')
      autoload :MessageAlreadyCreated,    action_root.join('message_already_created')
      autoload :MessageAlreadyTerminated, action_root.join('message_already_terminated')
      autoload :MessageCannotTerminate,   action_root.join('message_cannot_terminate')
      autoload :MessageNotCreated,        action_root.join('message_not_created')
      autoload :MessageNotRunning,        action_root.join('message_not_running')
      autoload :MessageProvisioningNotYetSupported, action_root.join('message_provisioning_not_yet_supported')
      autoload :ReadSSHInfo,              action_root.join('read_ssh_info')
      autoload :ReadState,                action_root.join('read_state')
      autoload :RunInstance,              action_root.join('run_instance')
      autoload :RemoveMachineId,          action_root.join('remove_machine_id')
      autoload :StartInstance,            action_root.join('start_instance')
      autoload :StopInstance,             action_root.join('stop_instance')
      autoload :SyncFolders,              action_root.join('sync_folders')
      autoload :TerminateInstance,        action_root.join("terminate_instance")
      autoload :TimedProvision,           action_root.join('timed_provision')
      autoload :WarnNetworks,             action_root.join('warn_networks')
    end
  end
end
