require 'fileutils'
require 'json'

module Oyaspirateur
  class Downloader
    class << self
      def save(folder, as = :json)
        case as
        when :write
          mkdir_cd(folder)
        when :simulate
          @current_path = ::File.dirname(__FILE__)
          fake_mkdir_cd(folder)
        else
          puts JSON.pretty_generate(folder.to_hash)
        end
      end

      private

      def fetch_in(folder, next_op)
        targets = []
        targets.concat(folder.files.map(&:url))
        targets.concat(folder.pictures.map(&:url))

        yield targets if targets.length > 0

        folder.folders.each do |f|
          send(next_op, f)
        end
      end

      def fake_mkdir_cd(folder)
        fake_cd(folder.name) do
          fetch_in(folder, :fake_mkdir_cd) do |targets|
            puts targets
          end
        end
      end

      def fake_cd(folder_name)
        @current_path = ::File.join(@current_path, folder_name)
        puts 'Change directory to: ' + @current_path
        return unless block_given?
        yield
        @current_path = ::File.split(@current_path).first
        puts 'Change directory to: ' + @current_path
      end

      def mkdir_cd(folder)
        FileUtils.mkdir_p(folder.name, verbose: true)
        FileUtils.cd(folder.name, verbose: true) do
          fetch_in(folder, :mkdir_cd) do |targets|
            puts `wget #{targets.join(' ')}`
          end
        end
      end
    end
  end
end
