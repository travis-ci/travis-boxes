module Travis
  module Boxes
    class Remote

      URL = "files.travis-ci.org"
      USER = "travis"

      def upload(source, destination)
        full_source = Pathname.new(source)
        relative_destination = "boxes/#{destination}"

        puts "Uploading #{source} to #{relative_destination}"

        STDOUT.sync = true
        system("ssh travis@files.travis-ci.org 'mkdir -p #{destination}'")
        system("rsync -avz --progress #{source} travis@files.travis-ci.org:#{relative_destination}")
      end

      def symlink(source, target)
        puts "Creating symlink"
        STDOUT.sync = true
        system("ssh travis@files.travis-ci.org 'ln -nfs ~/boxes/#{source} ~/boxes/#{target}'")
        puts "Symlink created"
      end

    end
  end
end

