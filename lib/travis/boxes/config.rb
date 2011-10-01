require 'yaml'
require 'hashr'

module Travis
  module Boxes
    class Config < Hashr
      define :base      => 'lucid32_new.box',
             :cookbooks => 'vendor/travis-cookbooks',
             :json      => {},
             :recipes   => []

      def initialize(type)
        super(read(type))
      end

      protected

        def read(type)
          read_yml('base').merge(read_yml(type))
        end

        def read_yml(type)
          YAML.load_file(path(type)) || {}
        end

        def path(type)
          filename = ['config/worker', type, 'yml'].compact.join('.')
          path = File.expand_path(filename)
          File.exists?(path) ? path : raise("Could not find a configuration file #{path}")
        end
    end
  end
end

