require 'spec_helper'

describe_resource Chef::Resource::Libartifact do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: 'libartifact').converge('artifact-test::default')
  end

  context 'with default attributes' do
    it 'converges successfully' do
      chef_run
    end
  end
end
