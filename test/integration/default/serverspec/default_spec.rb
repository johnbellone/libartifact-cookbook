require 'spec_helper'

describe file('/srv/twbs') do
  it { should be_directory }
  it { should be_owned_by 'twbs' }
  it { should be_grouped_into 'twbs' }
end

describe file('/srv/twbs/current') do
  it { should be_symlink }
  it { should be_linked_to '/srv/tws/3.3.4' }
  it { should be_owned_by 'twbs' }
  it { should be_grouped_into 'twbs' }
end

describe file('/srv/twbs/3.3.4') do
  it { should be_directory }
  it { should be_owned_by 'twbs' }
  it { should be_grouped_into 'twbs' }
end

describe file('/srv/twbs/3.3.2') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/srv/twbs/3.3.1') do
  it { should_not exist }
end
