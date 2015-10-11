module Oyaspirateur
  class Site
    attr_reader :root_url

    def initialize(architecture)
      @root_url = architecture[:root_url]
      @paths = architecture[:paths]
      @refs = architecture[:refs]
      define_helpers [@paths, :url], [@refs, :ref]
    end

    private

    def url_for(path_name)
      @root_url + @paths[path_name]
    end

    def ref_for(ref_name)
      @refs[ref_name]
    end

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end

    def method_name(key, suffix)
      suffix == :url ? :"#{key}_#{suffix}" : key
    end

    def getter_name(suffix)
      :"#{suffix}_for"
    end

    def define_helpers(*helper_confs)
      helper_confs.each do |items, suffix|
        items.each_key do |key|
          create_method(method_name(key, suffix)) do
            send(getter_name(suffix), key)
          end
        end
      end
    end
  end
end
