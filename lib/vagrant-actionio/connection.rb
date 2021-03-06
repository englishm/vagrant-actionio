require 'vagrant-actionio/util/env'
require 'vagrant-actionio/errors'
require 'vagrant-actionio/version'
require 'oauth2'

ENV['SSL_CERT_FILE'] = File.join(File.expand_path('../../../', __FILE__), '/data/cacert.pem')

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
        options = { site: HOST }
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
        if e.response && e.response.status == 401
          raise Errors::APIError, 'invalid_access_token'
        else
          raise e
        end
      else
        if response.status == 200
          json = JSON.parse(response.body)
          if json.kind_of?(Hash) && json['scopes'].split.include?('boxes')
            return
          else
            raise Errors::APIError, 'invalid_access_token_scope'
          end
        end
      end

      def fetch_box_state(box_id)
        begin
          response = request(:get, "/boxes/#{box_id}")
        rescue => e
          if e.respond_to?(:response) && e.response.status == 404
            # The box can't be found
            return nil
          else
            raise e
          end
        end

        response.parsed['box']['state'].to_sym
      end
    end
  end
end
