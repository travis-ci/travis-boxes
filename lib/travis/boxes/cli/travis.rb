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

      end
    end
  end
end
