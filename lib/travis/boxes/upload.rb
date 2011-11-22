require 'right_aws'

module Travis
  module Boxes
    class Upload
      attr_reader :env, :config

      def initialize(config)
        @config = config
      end

      def perform(source, destination)
        contents = Pathname.new(source).open
        s3.put(bucket, destination, contents)
      end

      protected

        def s3
          RightAws::S3.new(config.access_key_id, config.secret_access_key).interface
        end

        def bucket
          config.bucket
        end

    end
  end
end

