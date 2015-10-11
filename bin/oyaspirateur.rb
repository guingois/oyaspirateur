#!/usr/bin/env ruby

require 'mechanize'
require_relative '../lib/oyaspirateur/site'
require_relative '../lib/oyaspirateur/crawler'
require_relative '../lib/oyaspirateur/downloader'

user = Struct.new(:email, :password).new(ARGV[0], ARGV[1])

conf_file = ARGV[3]
default_conf_file = File.join(File.dirname(__FILE__), '../oyarchitecture.yml')

oyarchitecture = YAML.load_file(conf_file || default_conf_file)

agent   = Mechanize.new
site    = Oyaspirateur::Site.new(oyarchitecture)
crawler = Oyaspirateur::Crawler.new(agent, site)

agent.get(site.login_url) do |login_page|
  login_page.form_with(id: site.login_form) do |login_form|
    login_form['name'] = user.email
    login_form['pass'] = user.password
  end.submit

  crawler.crawl('oyalbum')

  Oyaspirateur::Downloader.save(crawler.results)
end
