require 'spec_helper'

describe 'Artifact Remote File' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: 'libartifact_file').converge('artifact-test::default')
  end

  context 'with default attributes' do
    it 'converges successfully' do
      chef_run
    end
  end
end
