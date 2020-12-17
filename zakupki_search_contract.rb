require 'sequel'
require 'nokogiri'
require 'open-uri'

db = Sequel.connect('sqlite://db/zakupki.sqlite3')
regions = db[:regions]

regions.each { |region| puts region }

#puts "Введите номер региона"
#region_user_input = gets.chomp

#puts "Введите дату"
#data_user_input = gets.chomp

#regions.each { |reg| region = reg[:name] if reg[:id] == region_user_input  }

#region_passport_url = "https://zakupki.gov.ru/epz/opendata/card/passport-info.html?passportId=#{region}"

#doc = Nokogiri::HTML(open(region_passport_url, 'User-Agent' => user_agent, 'read_timeout' => '10' ), nil, "UTF-8")

#ftp_url = doc.xpath("//div/section/span/a[@class='cancelCustomBlockUI']/@href").text

