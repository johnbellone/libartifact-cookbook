#
# Cookbook: libartifact-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
module LibartifactCookbook
  module Helpers
    # @!classmethods
    module ClassMethods
      def friendly_name(name, version, extension)
        "#{name}-#{version}.#{extension}"
      end

      def cached_filename(name, version, extension)
        File.join(Chef::Config[:file_cache_path], friendly_filename(name, version, extension))
      end

      def shared_path(name)
        File.join(base_path, name, 'shared')
      end

      def current_path(name)
        File.join(base_path, name, 'current')
      end

      def release_directory(name, version)
        File.join(base_path, name, 'releases', version)
      end

      def releases_path(name)
        File.join(base_path, name, 'releases')
      end
    end

    extend ClassMethods
  end
end
