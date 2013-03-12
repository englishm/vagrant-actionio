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
      #def self.action_read_state
      #end

      # This action is called to SSH into the machine.
      #def self.action_ssh
      #end

      # This action is called to bring the box up from nothing.
      #def self.action_up
      #end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      #autoload :ConnectActionIO, action_root.join("connect_actionio")
    end
  end
end
