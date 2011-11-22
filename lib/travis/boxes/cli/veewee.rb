require 'archive/tar/minitar'
require 'json'
require 'travis/boxes'

module Travis
  module Boxes
    module Cli
      class Veewee < Thor
        namespace "travis:veewee"

        include Cli

        desc 'build', 'Build a base box from a veewee definition(eg. natty32.box)'
        method_option :definition, :aliases => '-d', :default => 'natty32', :desc => 'Definition to build the base box from (e.g. natty32)'
        method_option :upload,     :aliases => '-u', :desc => 'Upload the box'

        def build
          run <<-sh
            vagrant basebox build '#{options['definition']}'
            vagrant basebox export #{options['definition']}
            mkdir -p boxes
            mv #{options['definition']}.box boxes/#{options['definition']}.box
          sh
        end

        desc 'upload', 'Upload a base box'
        method_option :definition, :aliases => '-d', :default => 'natty32', :desc => 'Definition of the box to upload (e.g. natty32)'

        def upload
          source = "boxes/#{options['definition']}.box"
          target = "boxes/bases/#{options['definition']}.box"

          ::Travis::Boxes::Upload.new(config.s3).perform(source, target)
        end

        protected

          def vbox
            @vbox ||= Vbox.new('', options)
          end

          def config
            @config ||= ::Travis::Boxes::Config.new
          end

          def env
            options['env']
          end
      end
    end
  end
end
