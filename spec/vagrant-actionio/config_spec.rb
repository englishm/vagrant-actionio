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
    its('box_name')     { should be_nil }
    its('stack')        { should eq 'rails' }
    its("ssh_private_key_path") { should be_nil }
  end

  describe "overriding defaults" do
    [:access_token, :region, :stack, :box_name, :ssh_private_key_path].each do |attribute|
      it "should not default #{attribute} if overridden" do
        instance.send("#{attribute}=".to_sym, 'foo')
        instance.finalize!
        expect(instance.send(attribute)).to eq 'foo'
      end
    end
  end
end
