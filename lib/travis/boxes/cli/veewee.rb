require 'archive/tar/minitar'
require 'json'
require 'travis/boxes'

module Travis
  module Boxes
    module Cli
      class Veewee < Thor
        namespace "travis:veewee"

        include Cli

        desc 'build', 'Build a base box (only the development box by default)'
        method_option :base,   :aliases => '-b', :default => 'natty32', :desc => 'Base box for this box (e.g. natty32)'
        method_option :upload, :aliases => '-u', :desc => 'Upload the box'

        def build
          run <<-sh
            vagrant basebox build '#{options['base']}'
            vagrant basebox export   #{options['base']}
            mkdir -p boxes
            mv #{options['base']}.box boxes/#{options['base']}.box
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
