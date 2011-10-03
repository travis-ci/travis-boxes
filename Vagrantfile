$: << 'lib'
require 'travis/boxes'

ENV_REGEX = /config\/worker\.(\w+)\.yml/

# reads the files in the config dir and uses them as envs
envs = Dir['config/*'].map do |dir|
  match = ENV_REGEX.match(dir)

  if (match && match[1] != 'base')
    env = match[1]
    [env, Travis::Boxes::Config.new[env]]
  else
    nil
  end
end.compact

envs = Hash[envs]

puts "Environments detected : #{envs.keys.join(', ')}\n\n"


Vagrant::Config.run do |c|
  envs.each_with_index do |(name, config), num|

    full_name = "travis-#{name}"

    c.vm.define(full_name) do |box|
      box.vm.box = full_name
      box.vm.forward_port('ssh', 22, 2220 + num)

      box.vm.customize do |vm|
        vm.name = "#{full_name}-base"
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
