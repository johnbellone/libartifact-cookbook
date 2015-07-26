require 'poise_boiler/spec_helper'
require_relative '../../../libraries/libartifact_file'

describe LibArtifactCookbook::Resource::ArtifactFile do
  step_into(:libartifact_file)
  context '#action_create' do
    before do
      recipe = double('Chef::Recipe')
      allow_any_instance_of(Chef::RunContext).to receive(:include_recipe).and_return([recipe])
      allow_any_instance_of(Chef::Provider).to receive(:libarchive_file).and_return(true)
    end

    recipe do
      libartifact_file 'twbs-v3.3.2' do
        install_path '/srv'
        artifact_name 'twbs'
        artifact_version '3.3.2'
        remote_url 'http://foo.bar.baz'
        remote_checksum 'qux'
      end
    end

    it { is_expected.to create_directory('/srv/twbs') }
    it { is_expected.to create_link('/srv/twbs/current').with(to: '/srv/twbs/3.3.2') }
  end

  context '#action_delete' do
    recipe do
      libartifact_file 'twbs-v3.3.2' do
        install_path '/srv'
        artifact_name 'twbs'
        artifact_version '3.3.2'
        remote_url 'http://foo.bar.baz'
        remote_checksum 'qux'
        action :delete
      end
    end

    it { is_expected.to delete_link('/srv/twbs/current') }
    it { is_expected.to delete_directory('/srv/twbs/3.3.2') }
  end
end
