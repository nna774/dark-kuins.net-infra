node[:basedir] = File.expand_path('..', __FILE__)
node[:mitamae] = Object.const_defined?(:MItamae)

if node[:mitamae]
  include_recipe './site_mitamae.rb'
else
  include_recipe './site_itamae.rb'
end

execute 'systemctl daemon-reload' do
  action :nothing
end

execute 'apt-get update' do
  action :nothing
end

execute 'update-grub' do
  action :nothing
end

define :apt_key, keyname: nil do
  name = params[:keyname] || params[:name]
  execute "apt-key #{name}" do
    command "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys #{name}"
    not_if "apt-key export #{name} | grep -q PGP"
  end
end

case node[:platform]
when 'ubuntu'
  node[:release] = {
    '14.04' => :trusty,
    '16.04' => :xenial,
    '18.04' => :bionic,
    '19.04' => :disco,
    '19.10' => :eoan,
    '20.04' => :focal,
    '22.04' => :jammy,
  }.fetch(node[:platform_version])
  node[:is_systemd] = node[:release] != '14.04'
when 'debian'
  node[:release] =  {
    '7' => :wheezy,
    '8' => :jessie,
    '9' => :stretch,
    '10' => :buster,
    '11' => :bullseye,
    '12' => :bookworm,
  }.fetch(node[:platform_version].split('.', 2)[0])
  node[:is_systemd] = node[:release] != '7'
when 'arch'
  node[:is_systemd] = true
end
