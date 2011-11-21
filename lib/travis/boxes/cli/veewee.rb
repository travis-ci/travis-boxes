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
            vagrant basebox export   #{options['definition']}
            mkdir -p boxes
            mv #{options['definition']}.box boxes/#{options['definition']}.box
          sh
        end

        desc 'upload', 'Upload a base box'
        method_option :env, :aliases => '-e', :default => 'development', :desc => 'Environment the box is built for (e.g staging)'

        def upload
          Travis::Boxes::Upload.new(env, config.s3).perform
        end
      end
    end
  end
end
