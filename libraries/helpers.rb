#
# Cookbook: libartifact-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
module ArtifactCookbook
  module Helpers
    extend self

    def friendly_name(name, version, extension)
      "#{name}-#{version}.#{extension}"
    end

    # @param filename [String]
    def cached_filename(name, version, extension)
      File.join(Chef::Config[:file_cache_path], friendly_filename(name, version, extension))
    end

    # @param name [String] Unique value for name of the artifact.
    def shared_path(name)
      File.join(base_path, name, 'shared')
    end

    # @param name [String] Unique value for name of the artifact.
    def current_path(name)
      File.join(base_path, name, 'current')
    end

    # @param name [String] Unique value for name of the artifact.
    # @param version [String] Unique value for version of the artifact.
    def release_directory(name, version)
      File.join(base_path, name, 'releases', version)
    end

    # @param name [String] Unique value for name of the artifact.
    def releases_path(name)
      File.join(base_path, name, 'releases')
    end
  end
end
