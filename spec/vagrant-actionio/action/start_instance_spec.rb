require 'vagrant-actionio/action/start_instance'

describe VagrantPlugins::ActionIO::Action::StartInstance do
  let(:app) { double 'app', call: nil }
  let(:config) { double 'config', region: 'ap-southeast-1', box_name: 'petes-node-box', stack: 'nodejs' }
  let(:machine) { OpenStruct.new id: 777, provider_config: config }
  let(:actionio) { double 'connection', request: nil }
  let(:ui) { double 'ui', info: nil, warn: nil }
  let(:env) { { actionio: actionio, machine: machine, ui: ui } }
  let(:instance) { described_class.new(app, env) }

  describe '#start_box' do
    let(:json) { '{"box":{"id":777,"state":"starting"}}' }
    let(:response) { double 'response', status: 200, json: json, parsed: JSON.parse(json) }

    it 'runs the request' do
      actionio.should_receive(:request).with(:put, '/boxes/777/start').and_return response
      instance.start_box(actionio, machine)
    end
  end
end
