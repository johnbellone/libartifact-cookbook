# libartifact-cookbook
[Library cookbook][1] for managing release artifacts.

This cookbook offers an opinionated workflow for management of release
artifacts on a system. The intention here is that a current symlink
exists, the new artifact is unpacked and the symlink is
re-linked. There isn't anything fancy here - you'll need to perform
any additional actions yourself.

## Usage
This library provides a single resource/provider which is used to
manage archives on the system. It requires the
[libarchive library cookbook][3] to handle the unpacking.

Here is an example recipe to install the [Redis database][2] from
source. Remember the intent here is that you'll manage restarting
services (if necessary, obviously).
```ruby
include_recipe 'build-essential::default'

source_version = node['redis']['source_version']
artifact = libartifact_file "redis-#{source_version}" do
  artifact_name 'redis'
  artifact_version source_version
  remote_url node['redis']['source_url']
  remote_checksum node['redis']['source_checksum']
  owner node['redis']['user']
  group node['redis']['group']
  notifies :run, 'execute[make]', :immediately
end

execute 'make' do
  action :nothing
  cwd artifact.current_path
end
```

[1]: http://blog.vialstudios.com/the-environment-cookbook-pattern/#thelibrarycookbook
[2]: http://redis.io/
[3]: https://github.com/reset/libarchive-cookbook
