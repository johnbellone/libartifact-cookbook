#
# Cookbook: libartifact-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

class Chef::Resource::LibartifactFile < Chef::Resource::LWRPBase
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
            kind_of: String,
            required: true)
  attribute(:group,
            kind_of: String,
            required: true)
end
