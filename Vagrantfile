$: << 'lib'
require 'travis/boxes'

config = Travis::Boxes::Config.new(ENV['ENV'] || 'development')
envs = %w(development staging ruby rails erlang)

Vagrant::Config.run do |c|
  envs.each_with_index do |name, num|

    c.vm.define(name) do |c|
      c.vm.box = name
      c.vm.forward_port('ssh', 22, 2220 + num)

      if config.recipes? && File.directory?(config.cookbooks)
        c.vm.provision :chef_solo do |chef|
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
