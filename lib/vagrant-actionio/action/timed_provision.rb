require 'vagrant-actionio/util/timer'

module VagrantPlugins
  module ActionIO
    module Action
      # This is the same as the builtin provision except it times the
      # provisioner runs.
      class TimedProvision < Vagrant::Action::Builtin::Provision
        def run_provisioner(env, prov)
          timer = Util::Timer.time do
            super
          end

          env[:metrics] ||= {}
          env[:metrics]["provisioner_times"] ||= []
          env[:metrics]["provisioner_times"] << [prov.class.to_s, timer]
        end
      end
    end
  end
end
