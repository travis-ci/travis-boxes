require 'archive/tar/minitar'
require 'json'
require 'travis/boxes'

module Travis
  module Boxes
    module Cli
      class Veewee < Thor
        namespace "travis:base"

        include Cli

        desc 'build', 'Build a base box from a veewee definition(eg. natty32.box)'
        method_option :definition, :aliases => '-d', :default => 'natty32', :desc => 'Definition to build the base box from (e.g. natty32)'
        method_option :upload,     :aliases => '-u', :desc => 'Upload the box'

        def build
          run <<-sh
            vagrant basebox build '#{definition}'
            vagrant basebox export #{definition}
            mkdir -p boxes
            mv #{definition}.box boxes/#{definition}.box
          sh
        end

        desc 'upload', 'Upload a base box'
        method_option :definition, :aliases => '-d', :default => 'natty32', :desc => 'Definition of the box to upload (e.g. natty32)'

        def upload
          remote = ::Travis::Boxes::Remote.new
          remote.upload("boxes/#{definition}.box", "bases/#{definition}.box")
        end

        protected

          def vbox
            @vbox ||= Vbox.new('', options)
          end

          def config
            @config ||= ::Travis::Boxes::Config.new
          end

          def definition
            options['definition']
          end
      end
    end
  end
end
