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

  def load_current_resource
    @current_resource = Chef::Resource::LibartifactFile.new(@new_resource.name)
    @current_resource.artifact_name(@new_resource.artifact_name)
    @current_resource.artifact_version(@new_resource.artifact_version)
    @current_resource.install_path(@new_resource.install_path)
    @current_resource.remote_url(@new_resource.remote_url)
    @current_resource.remote_checksum(nil)
    @current_resource.owner(@new_resource.owner)
    @current_resource.group(@new_resource.group)

    if File.symlink?(current_path(@current_resource.artifact_name))
      filename = File.readlink(current_path(@current_resource.artifact_name))
      @current_resource.artifact_version(filename)
    end

    @current_resource
  end

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
      to current_path(@new_resource.artifact_name)
    end
  end

  action :delete do
    artifact_release_dir = release_directory(@new_resource.artifact_name,
                                             @new_resource.artifact_version)

    link artifact_release_dir do
      to current_path(@new_resource.artifact_name)
      action :delete
    end

    file artifact_release_dir do
      action :delete
      only_if { File.exist?(path) }
    end
  end
end
