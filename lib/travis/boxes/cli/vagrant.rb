require 'archive/tar/minitar'
require 'json'
require 'travis/boxes'

module Travis
  module Boxes
    module Cli
      class Vagrant < Thor
        namespace "travis:box"

        include Cli

        desc 'build', 'Build a base box (only the development box by default)'
        method_option :definition,  :aliases => '-d', :default => 'development', :desc => 'Box definition used for configuration (e.g staging)'
        method_option :base,        :aliases => '-b', :desc => 'Base box for this box (e.g. natty32.box)'
        method_option :upload,      :aliases => '-u', :desc => 'Upload the box'
        method_option :reset,       :aliases => '-r', :type => :boolean, :default => false, :desc => 'Force reset on virtualbox settings and boxes'

        def build
          vbox.reset if options['reset']

          download
          add_box
          exit unless up

          package_box
          upload if upload?
        end

        desc 'upload', 'Upload a base box'
        method_option :definition,  :aliases => '-d', :default => 'staging', :desc => 'Box definition to upload (e.g staging)'

        def upload
          cached_timestamp = timestamp

          original    = "boxes/travis-#{definition}.box"
          destination = "provisioned/#{definition}/#{cached_timestamp}.box"

          remote = ::Travis::Boxes::Remote.new
          remote.upload(original, destination)
          remote.symlink(destination, "provisioned/#{definition}.box")
        end

        protected

          def vbox
            @vbox ||= Vbox.new('', options)
          end

          def config
            @config ||= ::Travis::Boxes::Config.new[definition]
          end

          def definition
            options['definition']
          end

          def upload?
            options['upload']
          end

          def base
            @base ||= options['base'] || config.base
          end

          def target
            @target ||= "boxes/#{base_box_name}.box"
          end

          def download
            run "mkdir -p boxes"
            run "wget #{base} -P boxes" unless File.exists?(base_name_and_path)
          end

          def add_box
            run "vagrant box remove #{base_box_name}"
            run "vagrant box add #{base_box_name} #{base_name_and_path}"
          end

          def up
            run "vagrant up #{base_box_name} --provision=true"
          end

          def halt
            run "vagrant halt #{base_box_name}"
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
            meta['active'][base_box_name] || raise("could not find #{base_box_name} uuid in #{meta.inspect}")
          end

          def base_box_name
            "travis-#{definition}"
          end

          def base_name_and_path
            "boxes/#{File.basename(base)}"
          end

          def timestamp
            Time.now.strftime('%Y-%m-%d-%H%M')
          end

      end
    end
  end
end
