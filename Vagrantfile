$: << 'lib'
require 'travis/boxes'

env = ENV['ENV'] || 'development'
config = Travis::Boxes::Config.new[env]
envs = %w(development staging ruby rails erlang)

Vagrant::Config.run do |c|
  envs.each_with_index do |name, num|

    c.vm.define(name) do |box|
      box.vm.box = name
      box.vm.forward_port('ssh', 22, 2220 + num)

      box.vm.customize do |vm|
        vm.memory_size = config.memory.to_i
      end

      if config.recipes? && File.directory?(config.cookbooks)
        box.vm.provision :chef_solo do |chef|
          chef.cookbooks_path = config.cookbooks
          chef.log_level = :debug # config.log_level

          config.recipes.each do |recipe|
            chef.add_recipe(recipe)
          end

          chef.json.merge!(config.json)
        end
      end
    end
  end
end
