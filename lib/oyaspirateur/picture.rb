module Oyaspirateur
  class Picture < File
    class << self
      def name_of(node)
        node.text
      end

      def url_of(node)
        node.uri.to_s.gsub(%r{\/?#{node.text}$}, "/#{node.text}")
      end
    end
  end
end
