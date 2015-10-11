module Oyaspirateur
  module Utils
    def self.href_of(node)
      node.attribute('href').value
    end

    def self.href_at(node, selector = 'a')
      href_of(node.at(selector))
    end
  end
end
