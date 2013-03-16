require 'vagrant-actionio/action/run_instance'

describe VagrantPlugins::ActionIO::Action::RunInstance do
  let(:app) { double 'app', call: nil }
  let(:config) { double 'config', region: 'ap-southeast-1', box_name: 'petes-node-box', stack: 'nodejs' }
  let(:machine) { OpenStruct.new id: nil, provider_config: config }
  let(:actionio) { double 'connection', request: nil }
  let(:ui) { double 'ui', info: nil, warn: nil }
  let(:env) { { actionio: actionio, machine: machine, ui: ui } }
  let(:instance) { VagrantPlugins::ActionIO::Action::RunInstance.new(app, env) }

  describe '#create_box' do
    before do
      json = '{"box":{"id":777,"state":"provisioning"}}'
      response = double 'response', status: 201, json: json, parsed: JSON.parse(json)
      actionio.should_receive(:request).with(:post, '/boxes', params: {
        box: { name: 'cold-box', region: 'arctic', box_template: 'scala' }
      }).and_return response
    end

    it "sets box's id in the environment" do
      instance.create_box(actionio, machine, 'cold-box', 'arctic', 'scala')
      expect(machine.id).to eq 777
    end
  end
end
