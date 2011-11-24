module Travis
  module Boxes
    class Remote

      URL = "files.travis-ci.org"
      USER = "travis"

      def upload(source, destination)
        full_source = Pathname.new(source)
        relative_destination = "boxes/#{destination}"

        STDOUT.sync = true
        system("rsync --progress #{source} travis@files.travis-ci.org:#{relative_destination}")
      end

      def symlink(target, symlink_to)

      end

    end
  end
end

