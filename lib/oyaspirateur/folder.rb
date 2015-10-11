require_relative './utils'

module Oyaspirateur
  class Folder < File
    class << self
      def name_of(node)
        node.search('span')
          .children
          .map(&:content)
          .join(' ')
          .gsub('&nbsp', '')
      end

      def url_of(node)
        Utils.href_at(node)
      end
    end

    attr_accessor :folders, :files, :pictures

    def initialize(*args)
      super(*args)
      @folders = []
      @files = []
      @pictures = []
    end

    def to_hash
      super.merge(
        folders: folders.map(&:to_hash),
        files: files.map(&:to_hash),
        pictures: pictures.map(&:to_hash)
      )
    end
  end
end
