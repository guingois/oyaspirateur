require_relative './file'
require_relative './folder'
require_relative './picture'
require_relative './utils'

module Oyaspirateur
  class Crawler
    attr_reader :agent,
                :site,
                :file_class,
                :folder_class,
                :picture_class

    def initialize(agent, site, *classes)
      @agent = agent
      @site  = site
      @file_class    = classes[0] || Oyaspirateur::File
      @folder_class  = classes[1] || Oyaspirateur::Folder
      @picture_class = classes[2] || Oyaspirateur::Picture
    end

    def fetch_page(url)
      agent.get(url)
    end

    def simple_viewer?(page)
      page.at(site.gallery_container_selector).children.first
        .content == 'START SIMPLEVIEWER EMBED.'
    end

    def parse(page)
      folders  = build_entities(page, :folder)
      files    = build_entities(page, :file)
      pictures = build_entities(page, :picture)
      yield folders, files, pictures
    end

    def build_entities(page, entity_name)
      send(:"list_#{entity_name.to_s}s", page).map do |entity_node|
        send(:"#{entity_name.to_s}_class").from_node(entity_node, site.root_url)
      end
    end

    def list_files(page)
      page.search(site.file_selector)
    end

    def list_folders(page)
      page.search(site.folder_selector)
    end

    def list_pictures(page)
      public_path = site.gallery_url_prefix[:public]
      simple_viewer_path = site.gallery_url_prefix[:simple_viewer]
      gallery_url = Utils.href_at(page, site.gallery_selector)
      gallery_url.gsub!(public_path, simple_viewer_path)
      fetch_page(gallery_url).links
    end

    def list_recursively(folder)
      parse(fetch_page(folder.url)) do |folders, files, pictures|
        folder.folders.concat(folders)
        folder.files.concat(files)
        folder.pictures.concat(pictures)
        folders.each { |f| list_recursively(f) }
      end
    end

    def crawl(root_name)
      @folder = folder_class.new(root_name, site.pictures_root_url)
      list_recursively(@folder)
    end

    def results
      @folder
    end
  end
end
