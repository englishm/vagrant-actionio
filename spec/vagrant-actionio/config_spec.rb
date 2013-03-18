require 'vagrant-actionio/config'

describe VagrantPlugins::ActionIO::Config do
  let(:instance) { described_class.new }

  describe 'defaults' do
    subject do
      instance.tap do |o|
        o.finalize!
      end
    end

    its('access_token') { should be_nil }
    its('region')       { should eq 'us-west-1' }
    its('stack')        { should eq 'rails' }
    its("ssh_private_key_path") { should be_nil }
  end

  describe 'overriding defaults' do
    [:access_token, :region, :stack, :ssh_private_key_path].each do |attribute|
      it "does not set default #{attribute} if overridden" do
        instance.send("#{attribute}=".to_sym, 'foo')
        instance.finalize!
        expect(instance.send(attribute)).to eq 'foo'
      end
    end
  end

  describe 'validation' do
    before do
      instance.access_token = nil
      instance.region = nil
      instance.stack = nil
      instance.ssh_private_key_path = nil

      machine = double 'machine'
      machine.stub_chain(:env, :root_path).and_return nil
      @errors = instance.validate(machine)['Action.IO Provider']
    end

    [:access_token, :region, :ssh_private_key_path].each do |attribute|
      it "requires #{attribute} to be specified" do
        expect(@errors).to include I18n.t("vagrant_actionio.config.#{attribute}_required")
      end
    end
  end
end
