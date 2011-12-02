require 'yaml'
require 'hashr'

module Travis
  module Boxes
    class Config
      class Definition < Hashr
        define :base      => 'natty32.box',
               :cookbooks => 'vendor/travis-cookbooks',
               :json      => {},
               :recipes   => []
      end

      attr_reader :definitions

      def initialize
        @definitions = {}
      end

      def definition(name)
        definitions[name.to_sym] ||= Definition.new(read(name.to_s))
      end
      alias :[] :definition

      def method_missing(name, *args, &block)
        args.empty? ? definition(name) : super
      end

      protected

        def read(name)
          base.merge(active_definition(name)).merge((local['base'] || {}).merge(local[name] || {})).merge('definition' => name)
        end

        def base
          read_yml('base')
        end

        def local
          read_yml
        end

        def active_definition(name)
          read_yml(name)
        end

        def read_yml(name = nil)
          path = self.path(name)
          File.exists?(path) ? path : raise("Could not find a configuration file #{path}")
          YAML.load_file(path) || {}
        end

        def path(name = nil)
          directory = name ? File.expand_path('../../../..', __FILE__) : '.'
          filename = ['config/worker', name, 'yml'].compact.join('.')
          [directory, filename].join('/')
        end
    end
  end
end

