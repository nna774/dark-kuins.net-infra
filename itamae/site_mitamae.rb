node[:secrets] =  MitamaeSecrets::Store.new(File.join('.','secrets'))
node[:basedir] = File.expand_path('..', __FILE__)

MItamae::RecipeContext.class_eval do
  def include_role(name)
    names = name.split("::")

    names << "default" if names.length == 1
    names[-1] += ".rb"

    common_candidates = [
      File.join(node[:basedir], 'roles', *names),
    ]
    candidates = [
      *common_candidates,
    ]

    candidates.each do |candidate|
      if File.exist?(candidate)
        include_recipe(candidate)
        return
      end
    end
    raise "Role #{name} couldn't found"
  end

  def include_cookbook(name)
    names = name.split("::")

    names << "default" if names.length == 1
    names[-1] += ".rb"

    common_candidates = [
      File.join(node[:basedir], 'cookbooks', *names),
    ]
    candidates = [
      *common_candidates,
    ]
    candidates.each do |candidate|
      if File.exist?(candidate)
        include_recipe(candidate)
        return
      end
    end
    raise "Cookbook #{name} couldn't found"
  end

  def data_bag(name)
    path = File.join(File.expand_path('../data_bags', __FILE__), "#{name}.yml")
    Hashie::Mash.new(YAML.load(File.read(path)))
  end
end
