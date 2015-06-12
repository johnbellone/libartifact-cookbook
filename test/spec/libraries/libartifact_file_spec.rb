require 'spec_helper'

describe 'LWRP: libartifact_file' do
  context 'with default attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: 'libartifact_file').converge('twbs::default')
    end

    it 'converges successfully' do
      chef_run
    end
  end
end
