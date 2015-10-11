require_relative './utils'

module Oyaspirateur
  class File
    class << self
      def name_of(node)
        node.content
      end

      def url_of(node)
        Utils.href_of(node)
      end

      def from_node(node, root_url)
        new(name_of(node), url_of(node), root_url)
      end
    end

    attr_reader :name, :url

    def initialize(name, url, root_url = '')
      @name = name.strip
      @url = root_url + url
    end

    def to_hash
      { name: name, url: url }
    end
  end
end
