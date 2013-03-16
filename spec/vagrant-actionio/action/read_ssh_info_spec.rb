require 'vagrant-actionio/action/read_ssh_info'
require 'ostruct'

describe VagrantPlugins::ActionIO::Action::ReadSSHInfo do
  let(:app) { double 'app', call: nil }
  let(:instance) { VagrantPlugins::ActionIO::Action::ReadSSHInfo.new(app, env) }

  context 'when machine id is nil' do
    let(:machine) { double 'machine', id: nil }
    let(:env) { { actionio: nil, machine: machine } }

    it 'returns nil' do
      instance.call(env)
      expect(env[:machine_ssh_info]).to be_nil
    end
  end

  context 'when machine id is not nil' do
    let(:machine) { OpenStruct.new(id: 123) }
    let!(:actionio) { double 'connection', request: nil }
    let(:env) { { actionio: actionio, machine: machine } }

    context 'when request is successful' do
      before do
        json = '{"box":{"id":123,"host":"foo-box-123.usw1.actionbox.io","port":12345}}'
        response = double 'response', status: 200, body: json, parsed: JSON.parse(json)
        actionio.should_receive(:request).with(:get, '/boxes/123').and_return response
        machine.stub_chain(:provider_config, :ssh_private_key_path).and_return '/home/action/.ssh/id_rsa'
      end

      it 'makes a get request to /boxes/:id and returns a hash containing the ssh info' do
        instance.call(env)
        expect(env[:machine_ssh_info]).to eq({
          host: 'foo-box-123.usw1.actionbox.io',
          port: 12345,
          private_key_path: '/home/action/.ssh/id_rsa',
          username: 'action'
        })
      end
    end

    context 'when request returns 404' do
      before do
        response = double 'response', status: 404
        error = StandardError.new('request error')
        error.stub(:response) { response }
        actionio.should_receive(:request).with(:get, '/boxes/123').and_raise error
      end

      it 'sets machine id to be nil and returns nil' do
        instance.call(env)
        expect(env[:machine].id).to be_nil
        expect(env[:machine_ssh_info]).to be_nil
      end
    end
  end
end

