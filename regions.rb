require 'nokogiri'
require 'open-uri'
require 'sequel'

db = Sequel.connect('sqlite://db/zakupki.sqlite3')
regions = db.from[:regions]

url = "https://zakupki.gov.ru/epz/opendata/search/results.html?morphology=on&dataset44IdHidden=5&dataset44IdNameHidden=%7B%7D&dataset223IdNameHidden=%7B%7D&dataset615IdNameHidden=%7B%7D&pageNumber=1&sortDirection=false&recordsPerPage=_10&showLotsInfoHidden=false"

user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"

doc = Nokogiri::HTML(open(url, 'User-Agent' => user_agent,
                          'read_timeout' => '10' ), nil, "UTF-8")

regions_on_page = doc.xpath("//div[@id='search-registry-entrys-block']//div[@class='text-break registry-entry__header-mid__number']/a/text()").map { |x| x.to_s.delete("\n").strip }


regions_on_page.each do |region|
  regions.insert(name: region)
end
