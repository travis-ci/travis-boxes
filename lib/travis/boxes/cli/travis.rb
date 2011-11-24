require 'archive/tar/minitar'
require 'json'
require 'travis/boxes'

module Travis
  module Boxes
    module Cli
      class Travis < Thor
        namespace "travis"

        include Cli

        desc 'init', 'Add a config/worker.yml'

        def init
          run <<-sh
            touch config/worker.yml
          sh
        end


        desc 'update_cookbooks', 'Update the cookbooks found at ../travis-cookbooks by doing a git pull'

        def update_cookbooks
          run "cd ../travis-cookbooks && git pull"
        end

      end
    end
  end
end
