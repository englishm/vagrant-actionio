require 'vagrant-actionio/connection'

describe VagrantPlugins::ActionIO::Connection do
  let(:connection) { VagrantPlugins::ActionIO::Connection.new('4cc35570k3n') }

  describe 'constructor' do
    it 'initializes client and token' do
      expect(connection.client).to be_an OAuth2::Client
      expect(connection.client.id).to eq described_class::OAUTH_CLIENT_ID
      expect(connection.client.secret).to eq described_class::OAUTH_CLIENT_SECRET
      expect(connection.client.options[:raise_errors]).to be_false
      expect(connection.token).to be_an OAuth2::AccessToken
      expect(connection.token.client).to eq connection.client
      expect(connection.token.token).to eq '4cc35570k3n'
    end
  end

  describe '#request' do
    it 'delegates request to the token object' do
      connection.token.should_receive(:request).with :post,
        "#{described_class::API_PATH_PREFIX}/public_keys", parse: :json,
        params: {
          name: 'some-name',
          key: 'some-key'
        },
        headers: { 'User-Agent' => described_class::USER_AGENT }

      connection.request :post, '/public_keys',
        params: {
          name: 'some-name', key: 'some-key'
        }
    end
  end

  describe '#verify_access_token' do
    context 'when request returns response code 200' do
      before do
        connection.should_receive(:request).with(:get, '/scopes').and_return response
      end

      context 'when response json contains boxes scope' do
        let!(:response) { double 'response', status: 200, body: { scopes: 'public boxes'}.to_json }

        it 'does not raise any exception' do
          expect {
            connection.verify_access_token
          }.not_to raise_error
        end
      end

      context 'when response json does not contain boxes scope' do
        let!(:response) { double 'response', status: 200, body: { scopes: 'public'}.to_json }

        it 'raises APIError' do
          expect {
            connection.verify_access_token
          }.to raise_error VagrantPlugins::ActionIO::Errors::APIError
        end
      end
    end

    context 'when request returns response code 401' do
      before do
        response = double 'response', status: 401
        error = StandardError.new('request error')
        error.stub(:response) { response }
        connection.should_receive(:request).with(:get, '/scopes').and_raise error
      end

      it 'raises APIError' do
        expect {
          connection.verify_access_token
        }.to raise_error VagrantPlugins::ActionIO::Errors::APIError
      end
    end
  end

  describe '#fetch_box_state' do
    context 'when request is successful' do
      before do
        json = '{"box":{"id":123,"state":"running"}}'
        response = double 'response', stats: 200, body: json, parsed: JSON.parse(json)
        connection.should_receive(:request).with(:get, '/boxes/123').and_return response
      end

      it "returns the box's state" do
        state = connection.fetch_box_state(123)
        expect(state).to eq :running
      end
    end

    context 'when request returns 404' do
      before do
        response = double 'response', status: 404
        error = StandardError.new('request error')
        error.stub(:response) { response }
        connection.should_receive(:request).with(:get, '/boxes/123').and_raise error
      end

      it 'returns nil' do
        state = connection.fetch_box_state(123)
        expect(state).to be_nil
      end
    end
  end
end
