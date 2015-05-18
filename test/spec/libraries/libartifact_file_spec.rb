require 'spec_helper'

describe 'libartifact_file' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: 'libartifact_file').converge('twbs::default')
  end

  context 'with default attributes' do
    it 'converges successfully' do
      chef_run
    end
  end
end
