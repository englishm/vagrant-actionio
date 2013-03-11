require 'vagrant'

module VagrantPlugins
  module ActionIO
    class Config < Vagrant.plugin('2', :config)
      # The access token for accessing Action.IO API.
      #
      # @return [String]
      attr_accessor :access_token

      # The name of the Action.IO region in which to create the box.
      #
      # @return [String]
      attr_accessor :region

      # The name of the Action.IO box template to create the box.
      #
      # @return [String]
      attr_accessor :box_template

      # The path to the SSH private key to use with the Action.IO box.
      # This overrides the `config.ssh.private_key_path` variable.
      #
      # @return [String]
      attr_accessor :ssh_private_key_path

      def initialize(region_specific=false)
        @access_token         = UNSET_VALUE
        @region               = UNSET_VALUE
        @box_template         = UNSET_VALUE
        @ssh_private_key_path = UNSET_VALUE

        # Internal state (prefix with __ so they aren't automatically
        # merged)
        @__finalized = false
      end

      #-------------------------------------------------------------------
      # Internal methods.
      #-------------------------------------------------------------------

      def finalize!
        # The access token default to nil
        @access_token = nil if @access_token == UNSET_VALUE

        # Default region is usw-1
        @region = 'us-west-1' if @region == UNSET_VALUE

        # Box template defaults to rails
        @box_template = 'rails' if @box_template == UNSET_VALUE

        # The SSH values by default are nil, and the top-level config
        # `config.ssh` values are used.
        @ssh_private_key_path = nil if @ssh_private_key_path == UNSET_VALUE

        # Mark that we finalized
        @__finalized = true
      end

      def validate(machine)
        errors = []

        errors << I18n.t('vagrant_actionio.config.access_token_required') if @access_token.nil?
        errors << I18n.t('vagrant_actionio.config.region_required') if @region.nil?

        { 'Action.IO Provider' => errors }
      end
    end
  end
end
