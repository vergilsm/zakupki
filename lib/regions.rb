require 'nokogiri'
require 'open-uri'
require 'sequel'
require_relative 'urls.rb'

class Region
  def self.all_regions
    base_url = Url.base_url
    base_url2 = Url.base_url2
    user_agent = Url.user_agent
    doc = Url.doc(base_url, user_agent)
    doc2 = Url.doc(base_url2, user_agent)
    regions_on_page = Url.regions_on_page(doc)
    regions_on_page2 = Url.regions_on_page(doc2)

    db = Sequel.connect('sqlite://db/zakupki.sqlite3')
    regions = db[:regions]

    regions_on_page.each do |region|
      regions.insert(name: region) unless regions.any? { |reg| reg[:name] == region }
    end

    regions_on_page2.each do |region|
      regions.insert(name: region) unless regions.any? { |reg| reg[:name] == region }
    end

    regions.each { |region| puts region }
  end
end

Region.all_regions
