require 'vagrant-actionio/util/env'
require 'vagrant-actionio/errors'
require 'vagrant-actionio/version'
require 'oauth2'

module VagrantPlugins
  module ActionIO
    class Connection
      OAUTH_CLIENT_ID     = Util::Env.read_with_default('VAGRANT_ACTIONIO_OAUTH_ID', '414b8765a91db88e3d9d2a391eb19117a652b23ec7c1222fd61ddb59d0298072')
      OAUTH_CLIENT_SECRET = Util::Env.read_with_default('VAGRANT_ACTIONIO_OAUTH_SECRET', 'd64a2c76e05126366d9627f165978a2a810c6b853c853df805e22f7390e59950')
      VERIFY_SSL = ENV['VAGRANT_ACTIONIO_VERIFY_SSL'] != 'false'
      HOST       = Util::Env.read_with_default('VAGRANT_ACTIONIO_HOST', 'https://www.action.io')
      API_PATH_PREFIX = '/api/v0'
      USER_AGENT = "Vagrant-ActionIO/#{VERSION} (Vagrant #{Vagrant::VERSION}; #{RUBY_DESCRIPTION})"

      attr_accessor :client, :token

      def initialize(access_token_string)
        options = { site: HOST, raise_errors: false }
        options[:ssl] = { verify_mode: OpenSSL::SSL::VERIFY_NONE } if !VERIFY_SSL
        @client = OAuth2::Client.new(OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, options)
        @token = OAuth2::AccessToken.new(client, access_token_string)
      end

      def request(verb, path, options={})
        options = { parse: :json }.merge options
        options[:headers] ||= {}
        options[:headers]['User-Agent'] = USER_AGENT

        @token.request verb.to_sym, "#{API_PATH_PREFIX}#{path}", options
      end

      def verify_access_token
        response = request(:get, '/scopes')
      rescue => e
        if e.response.status == 401
          raise Errors::APIError, 'Access token is invalid.'
        else
          raise Errors::APIError, e.message
        end
      else
        if response.status == 200
          json = JSON.parse(response.body)
          if json.kind_of?(Hash) && json['scopes'].split.include?('boxes')
            return
          else
            raise Errors::APIError, 'Access token does not have "boxes" scope.'
          end
        end
      end
    end
  end
end
