#
# Cookbook: libartifact-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require_relative 'helpers'
require 'fileutils'

class Chef
  # The basic model for a release artifact.
  #
  # @since 1.0.0
  class Resource::LibartifactFile < Resource
    include Poise
    provides(:libartifact_file)

    actions(:create, :delete)
    default_action(:create)

    attribute(:artifact_name,
      kind_of: String,
      name_attribute: true,
      cannot_be: :empty)
    attribute(:artifact_version,
      kind_of: String,
      required: true)
    attribute(:install_path,
      kind_of: String,
      default: lazy { node['libartifact']['install_path'] },
      cannot_be: :empty)
    attribute(:remote_url,
      kind_of: String,
      required: true)
    attribute(:remote_checksum,
      kind_of: [String, NilClass],
      default: nil)
    attribute(:owner,
      kind_of: [String, NilClass],
      required: true,
      default: nil)
    attribute(:group,
      kind_of: [String, NilClass],
      required: true,
      default: nil)
  end

  # The provider which manages a release artifact from a remote URL.
  #
  # @since 1.0.0
  class Provider::LibartifactFile < Provider
    include LibartifactCookbook::Helpers
    include Poise
    provides(:libartifact_file)

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

    def action_create
      extension = File.extname(@new_resource.remote_url)
      cached_filename = cached_filename(@new_resource.artifact_name,
        @new_resource.artifact_version,
        extension)
      artifact_release_dir = release_directory(@new_resource.artifact_name,
        @new_resource.artifact_version)

      converge_by("#{@new_resource.name} - :create #{@new_resource.artifact_name}") do
        notifying_block do
          include_recipe 'libarchive::default'

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

          if @new_resource.owner || @new_resource.group
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
      end
    end

    def action_delete
      artifact_release_dir = release_directory(@new_resource.artifact_name,
        @new_resource.artifact_version)

      converge_by("#{@new_resource.name} - :delete #{@new_resource.artifact_name}") do
        notifying_block do
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
    end
  end
end
