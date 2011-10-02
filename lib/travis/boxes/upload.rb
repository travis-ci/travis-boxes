module Travis
  module Boxes
    class Upload
      attr_reader :env, :config

      def initialize(env, config)
        @env = env
        @config = config
      end

      def perform
        s3.put(bucket, target, source.open)
      end

      protected

        def s3
          RightAws::S3.new(config.access_key_id, config.secret_access_key).interface
        end

        def bucket
          config.bucket
        end

        def source
          Pathname.new("boxes/#{env}.box")
        end

        def target
          "boxes/#{env}/#{timestamp}.box"
        end

        def timestamp
          Time.now.strftime('%Y%m%d%H%M%S')
        end
    end
  end
end

