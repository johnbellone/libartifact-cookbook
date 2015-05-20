#
# Cookbook: libartifact-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'fileutils'

# Resource for a release artifact on the system.
# @since 1.0.0
class Chef::Resource::LibartifactFile < Chef::Resource
  include Poise(fused: true)
  provides(:libartifact_file)
  actions(:create, :delete)

  attribute(:artifact_name,
            kind_of: String,
            name_attribute: true,
            cannot_be: :empty)
  attribute(:artifact_version,
            kind_of: String,
            required: true)
  attribute(:install_path,
            kind_of: String,
            default: '/srv',
            cannot_be: :empty)
  attribute(:remote_url,
            kind_of: String,
            required: true,
            cannot_be: :empty)
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

  # Downloads the remote file, unpacks and creates a symlink.
  action(:create) do
    include_recipe 'libarchive::default'

    extension = File.extname(new_resource.remote_url)
    cached_filename = [new_resource.artifact_name,
                       new_resource.artifact_version,
                       extension].join('-')

    archive = remote_file cached_filename do
      source new_resource.remote_url
      checksum new_resource.remote_checksum
    end

    directory File.join(new_resource.base_path, 'releases') do
      recursive true
      owner new_resource.owner
      group new_resource.group
    end

    libarchive_file cached_filename do
      path archive.path
      extract_to new_resource.release_path
      extract_options :no_overwrite
    end

    if new_resource.owner || new_resource.group
      FileUtils.chown_R(new_resource.owner,
                        new_resource.group,
                        new_resource.release_path)
    end

    link new_resource.release_path do
      owner new_resource.owner
      group new_resource.group
      to new_resource.current_path
    end
  end

  # Removes the current symlink and deletes the release path.
  # @todo At some point it would make sense if this supported some
  # kind of smart rollback. Otherwise we're left with no current link.
  action(:delete) do
    link new_resource.release_path do
      to new_resource.current_path
      action :delete
    end

    directory new_resource.release_path do
      recursive true
      action :delete
    end
  end

  # The absolute path to the artifact's release directory.
  # @return [String]
  def release_path
    File.join(base_path, 'releases', new_resource.artifact_version)
  end

  # The absolute path to the current symlink for this artifact.
  # @return [String]
  def current_path
    File.join(base_path, 'current')
  end

  # The absolute path to the artifact installation directory.
  # @return [String]
  def base_path
    File.join(new_resource.install_path, new_resource.artifact_name)
  end
end
