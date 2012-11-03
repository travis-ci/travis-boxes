$: << 'lib'
require 'travis/boxes'

ENV_REGEX = /config\/worker\.(.+)\.yml/

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


Vagrant::Config.run do |c|
  envs.each_with_index do |(name, config), num|

    full_name = "travis-#{name}"

    c.ssh.username = ENV.fetch("TRAVIS_CI_ENV_USERNAME", "travis")

    c.vm.define(full_name) do |box|
      box.vm.box = full_name
      box.vm.forward_port(22, 3340 + num, :name => "ssh")

      box.vm.customize [
                        "modifyvm",   :id,
                        "--memory",   config.memory.to_s,
                        "--name",     "#{full_name}-base",
                        "--nictype1", "Am79C973",
                        "--cpus",     "2",
                        "--ioapic",   "on"
                       ]

      box.vm.provision :shell do |sh|
        sh.inline = <<-EOF
          /opt/ruby/bin/gem install chef --no-ri --no-rdoc --no-user-install
        EOF
      end

      if config.recipes? && File.directory?(config.cookbooks)
        box.vm.provision :chef_solo do |chef|
          chef.cookbooks_path = config.cookbooks
          chef.log_level = :debug # config.log_level
          chef.binary_path = "/opt/ruby/bin/"

          config.recipes.each do |recipe|
            chef.add_recipe(recipe)
          end

          chef.json.merge!(config.json)
        end
      end
    end
  end
end
