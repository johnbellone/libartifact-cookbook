libartifact_file 'twbs-v3.3.1' do
  artifact_name 'twbs'
  artifact_version '3.3.1'
  remote_url node['twbs']['remote_url']
  action [:create, :delete]
end

libartifact_file 'twbs-v3.3.2' do
  artifact_name 'twbs'
  artifact_version '3.3.2'
  remote_url node['twbs']['remote_url']
  remote_checksum '3d0f6922b830c7fa64ad35fd7eb5096cdd7f4ed9401a1b7bfc9cc008a669ebad'
  action :create
end

libartifact_file "twbs-v#{node['twbs']['version']}" do
  artifact_name 'twbs'
  artifact_version node['twbs']['version']
  remote_url node['twbs']['remote_url']
  remote_checksuwgem node['twbs']['checksum']
  action :create
end
