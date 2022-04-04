node[:basedir] = File.expand_path('..', __FILE__)
node[:secrets] = MitamaeSecrets::Store.new(File.join(node[:basedir],'secrets'))

execute 'systemctl daemon-reload' do
  action :nothing
end

execute 'apt-get update' do
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
  }.fetch(node[:platform_version])
  node[:is_systemd] = node[:release] != '14.04'
when 'debian'
  node[:release] =  {
    '7' => :wheezy,
    '8' => :jessie,
    '9' => :stretch,
  }.fetch(node[:platform_version].split('.', 2)[0])
  node[:is_systemd] = node[:release] != '7'
when 'arch'
  node[:is_systemd] = true
end

MItamae::RecipeContext.class_eval do
  ROLES_DIR = File.expand_path("../roles", __FILE__)
  def include_role(name)
    recipe_file = File.join(ROLES_DIR, name, "default.rb")
    include_recipe(recipe_file.to_s)
  end

  COOKBOOKS_DIR = File.expand_path("../cookbooks", __FILE__)
  def include_cookbook(name)
    names = name.split("::")
    names << "default" if names.length == 1
    names[-1] += ".rb"

    candidates = [
      File.join(COOKBOOKS_DIR, *names),
    ]
    candidates.each do |candidate|
      if File.exist?(candidate)
        include_recipe(candidate)
        return
      end
    end
    raise "Cookbook #{name} couldn't found"
  end

  DATA_BAGSS_DIR = File.expand_path('../data_bags', __FILE__)
  def data_bag(name, type: :yaml)
    case type
    when :yaml
      YAML.load(File.read(File.join(DATA_BAGSS_DIR, "#{name}.yml")))
    when :json
      JSON.parse(File.read(File.join(DATA_BAGSS_DIR, "#{name}.json")), symbolize_names: true)
    end
  end
end
