require 'thor'

$stdout.sync = true

module Travis
  module Boxes
    module Cli
      def run(*commands)
        normalize_commands(commands).each do |command|
          puts "$ #{command}"
          system command
        end
      end

      def wait(seconds)
        puts "waiting for #{seconds} seconds "
        1.upto(seconds) { putc '.' }
        puts
      end

      def normalize_commands(commands)
        commands.join("\n").split("\n").map { |c| c.strip }.reject { |c| c.empty? }
      end
    end
  end
end
