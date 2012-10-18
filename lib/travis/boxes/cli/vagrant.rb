require 'archive/tar/minitar'
require 'json'
require 'travis/boxes'
require 'vagrant'

module Travis
  module Boxes
    module Cli
      class Vagrant < Thor
        namespace "travis:box"

        include Cli

        desc 'build [BOX]', 'Build a base box (defaults to development)'
        method_option :base,   :aliases => '-b', :desc => 'Base box for this box (e.g. precise64_base.box)'
        method_option :upload, :aliases => '-u', :desc => 'Upload the box'
        method_option :reset,  :aliases => '-r', :type => :boolean, :default => false, :desc => 'Force reset on virtualbox settings and boxes'
        method_option :download,  :aliases => '-d', :type => :boolean, :default => false, :desc => 'Force base image to be redownloaded'
        def build(box = 'development')
          self.box = box
          puts "Using the '#{box}' image"
          vbox.reset if options['reset']

          download if options['download']
          add_box
          exit unless up

          package_box
          upload(box) if upload?
        end

        desc 'upload', 'Upload a base box (defaults to development)'
        def upload(box = 'development')
          self.box = box
          cached_timestamp = timestamp

          original    = "boxes/travis-#{box}.box"
          destination = "provisioned/#{box}/#{cached_timestamp}.box"

          remote = ::Travis::Boxes::Remote.new
          remote.upload(original, destination)
          remote.symlink(destination, "provisioned/travis-#{box}.box")
        end

        protected

          attr_accessor :box

          def vbox
            @vbox ||= Vbox.new('', options)
          end

          def config
            @config ||= ::Travis::Boxes::Config.new[box]
          end

          def upload?
            options['upload']
          end

          def base
            @base ||= (calculate_base_url(options['base']) || config.base)
          end

          def calculate_base_url(input)
            if input
              if (s = input.downcase).start_with?("http")
                s
              else
                "http://files.travis-ci.org/boxes/bases/#{s}.box"
              end
            else
              nil
            end
          end

          def target
            @target ||= "boxes/#{base_box_name}.box"
          end

          def download
            run "mkdir -p boxes"
            # make sure that boxes/travis-*.box in the end is a new downloaded box,
            # not some old box that will cause wget to append .1 to the name of new file. MK.
            run "rm -rf #{base_name_and_path}"
            run "wget #{base} -P boxes" unless File.exists?(base_name_and_path)
          end

          def add_box
            begin
              vagrant.cli("box", "remove", base_box_name)
            rescue ::Vagrant::Errors::BoxNotFound => e
            end
            vagrant.cli("box", "add", base_box_name, base_name_and_path)
            vagrant.boxes.reload!
            vagrant.reload!
          end

          def up
            vagrant.cli("destroy", base_box_name, "--force")
            vagrant.cli("up", base_box_name, "--provision")
          end

          def halt
            vagrant.cli("halt", base_box_name)
          end

          def package_box
            vagrant.cli("package", "--base", uuid)
            run <<-sh
              mkdir -p #{File.dirname(target)}
              mv package.box #{target}
            sh
          end

          def uuid
            meta = JSON.parse(File.read('.vagrant'))
            meta['active'][base_box_name] || raise("could not find #{base_box_name} uuid in #{meta.inspect}")
          end

          def base_box_name
            "travis-#{box}"
          end

          def base_name_and_path
            "boxes/#{File.basename(base)}"
          end

          def timestamp
            Time.now.strftime('%Y-%m-%d-%H%M')
          end

          def vagrant
            @vagrant ||= ::Vagrant::Environment.new(:ui_class => ::Vagrant::UI::Colored)
          end
      end
    end
  end
end
