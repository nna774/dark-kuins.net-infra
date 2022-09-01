require 'itamae/secrets'
require 'yaml'
require 'pathname'

node[:secrets] = Itamae::Secrets(File.join(__dir__, 'secrets'))

module RecipeHelper
  def include_role(name)
    Pathname.new(File.dirname(@recipe.path)).ascend do |dir|
      recipe_file = dir.join("roles", name, "default.rb")
      if recipe_file.exist?
        include_recipe(recipe_file.to_s)
        return
      end
    end

    raise "Role #{name} is not found."
  end

  def include_cookbook(name)
    names = name.split("::")
    names << "default" if names.length == 1
    names[-1] += ".rb"

    Pathname.new(File.dirname(@recipe.path)).ascend do |dir|
      recipe_file = dir.join("cookbooks", *names)
      if recipe_file.exist?
        include_recipe(recipe_file.to_s)
        return
      end
    end

    raise "Cookbook #{name} is not found."
  end

  def data_bag(name)
    Hashie::Mash.load(File.join(__dir__, 'data_bags', "#{name}.yml"))
  end
end

Itamae::Recipe::EvalContext.send(:include, RecipeHelper)
