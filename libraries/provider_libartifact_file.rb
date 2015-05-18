#
# Cookbook: libartifact-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require_relative 'helpers'
require 'fileutils'

class Chef::Provider::LibartifactFile < Chef::Provider::LWRPBase
  include Poise
  include ArtifactCookbook::Helpers

  action :create do
    include_recipe 'libarchive::default'

    extension = File.extname(@new_resource.remote_url)
    cached_filename = cached_filename(@new_resource.artifact_name,
                                      @new_resource.artifact_version,
                                      extension)
    artifact_release_dir = release_directory(@new_resource.artifact_name,
                                             @new_resource.artifact_version)

    archive = remote_file cached_filename do
      source @new_resource.remote_url
      checksum @new_resource.remote_checksum
    end

    directory shared_path(@new_resource.artifact_name) do
      recursive true
      owner @new_resource.owner
      group @new_resource.group
    end

    directory releases_path(@new_resource.artifact_name) do
      recursive true
      owner @new_resource.owner
      group @new_resource.group
    end

    libarchive_file cached_filename do
      path archive.path
      extract_to release_directory
      extract_options :no_overwrite
    end

    if new_resource.owner || new_resource.group
      FileUtils.chown_R(@new_resource.owner,
                        @new_resource.group,
                        artifact_release_dir)
    end

    link artifact_release_dir do
      owner @new_resource.owner
      group @new_resource.group
      to current_symlink(@new_resource.artifact_name)
    end
  end

  action :delete do
    file release_directory(@new_resource.artifact_name, @new_resource.artifact_version) do
      action :delete
      only_if { File.exist?(path) }
    end
  end
end
