require 'archive/tar/minitar'
require 'json'
require 'right_aws'
require 'travis/boxes'

module Travis
  module Boxes
    module Cli
      class Vagrant < Thor
        namespace "travis:box"

        include Cli

        desc 'build', 'Build a base box'
        method_option :env,    :aliases => '-e', :default => 'development', :desc => 'Environment the box is built for (e.g staging)'
        method_option :base,   :aliases => '-b', :desc => 'Base box for this box (e.g. lucid32.box)'
        method_option :upload, :aliases => '-u', :desc => 'Upload the box'
        method_option :reset,  :aliases => '-r', :type => :boolean, :default => false, :desc => 'Force reset on virtualbox settings and boxes'

        def rebuild
          ENV['ENV'] = env
          vbox.reset

          download
          add_box
          exit unless up

          package_box
          upload if upload?
        end

        desc 'upload', 'Upload a base box'
        method_option :env, :aliases => '-e', :default => 'development', :desc => 'Environment the box is built for (e.g staging)'

        def upload
          Travis::Boxes::Upload.new(env, config.s3).perform
        end

        protected

          def vbox
            @vbox ||= Vbox.new('', options)
          end

          def config
            @config ||= Travis::Boxes::Config.new[env]
          end

          def env
            options['env']
          end

          def upload?
            options['upload']
          end

          def base
            @base ||= options['base'] || config.base
          end

          def target
            @target ||= "boxes/#{env}.box"
          end

          def download
            run "wget http://files.vagrantup.com/#{File.basename(base)}" unless File.exists?(base)
          end

          def home_path
            @home_path ||= Pathname.new(File.expand_path('~/.vagrant.d'))
          end

          def boxes_path
            home_path.join('boxes')
          end

          def add_box
            run "vagrant box add #{env} #{base}"
          end

          def up
            run "vagrant up #{env} --provision=true"
          end

          def halt
            run "vagrant halt #{env}"
          end

          def package_box
            run <<-sh
              vagrant package --base #{uuid}
              mkdir -p #{File.dirname(target)}
              mv package.box #{target}
            sh
          end

          def uuid
            meta = JSON.parse(File.read('.vagrant'))
            meta['active'][env] || raise("could not find #{env} uuid in #{meta.inspect}")
          end

          # def immute_disk
          #   run <<-sh
          #     VBoxManage storageattach #{uuid} --storagectl "SATA Controller" --port 0 --device 0 --medium none
          #     VBoxManage modifyhd ~/VirtualBox\\\\ VMs/#{uuid}/box-disk1.vmdk/#{name} --type immutable
          #     VBoxManage storageattach #{uuid} --storagectl "SATA Controller" --port 0 --device 0 --medium #{name} --type hdd
          #   sh
          # end
      end
    end
  end
end
