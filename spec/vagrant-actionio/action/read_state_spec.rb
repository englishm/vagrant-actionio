require 'vagrant-actionio/action/read_state'
require 'ostruct'

describe VagrantPlugins::ActionIO::Action::ReadState do
  let(:app) { double 'app', call: nil }
  let(:instance) { VagrantPlugins::ActionIO::Action::ReadState.new(app, env) }

  context 'when machine id is nil' do
    let(:machine) { double 'machine', id: nil }
    let(:env) { { actionio: nil, machine: machine } }

    it 'sets the machine_state_id to be :not_created' do
      instance.call(env)
      expect(env[:machine_state_id]).to eq :not_created
    end
  end

  context 'when machine id is not nil' do
    let(:machine) { OpenStruct.new(id: 123) }
    let!(:actionio) { double 'connection', request: nil, fetch_box_state: nil }
    let(:env) { { actionio: actionio, machine: machine } }

    context 'when request is successful' do
      before do
        actionio.should_receive(:fetch_box_state).with(123).and_return :running
      end

      it 'makes a get request to /boxes/:id and returns the state' do
        instance.call(env)
        expect(env[:machine_state_id]).to eq :running
      end
    end

    context 'when request returns 404' do
      before do
        actionio.should_receive(:fetch_box_state).with(123).and_return nil
      end

      it 'sets machine id to be nil and returns :not_created' do
        instance.call(env)
        expect(env[:machine].id).to be_nil
        expect(env[:machine_state_id]).to eq :not_created
      end
    end
  end
end
