require 'nokogiri'
require 'open-uri'
require 'sequel'
require_relative 'lib/regions.rb'
require_relative 'lib/urls.rb'

load_regions = Region.new

base_url = Url.base_url
user_agent = Url.user_agent
doc = Url.doc(base_url, user_agent)
regions_on_page = Url.regions_on_page(doc)

load_regions.all_regions(regions_on_page)

db = Sequel.connect('sqlite://db/zakupki.sqlite3')
regions = db[:regions]

regions.each { |region| puts region }
