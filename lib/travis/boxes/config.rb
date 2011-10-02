require 'yaml'
require 'hashr'

module Travis
  module Boxes
    class Config
      class Environment < Hashr
        define :base      => 'lucid32_new.box',
               :cookbooks => 'vendor/travis-cookbooks',
               :json      => {},
               :recipes   => [],
               :s3        => { :bucket => 'travis-boxes' }
      end

      attr_reader :environments

      def initialize
        @environments = {}
      end

      def environment(name)
        environments[name.to_sym] ||= Environment.new(read(name.to_s))
      end
      alias :[] :environment

      def method_missing(name, *args, &block)
        args.empty? ? environment(name) : super
      end

      protected

        def read(name)
          base.merge(env(name)).merge((local['base'] || {}).merge(local[name] || {})).merge(:env => name)
        end

        def base
          read_yml('base', true)
        end

        def env(name)
          read_yml(name, true)
        end

        def local
          read_yml
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

