require 'sequel'
require_relative 'lib/regions.rb'
require_relative 'lib/zip_list.rb'
require_relative 'lib/extract_zip.rb'
require_relative 'lib/open_xml.rb'

db = Sequel.connect('sqlite://db/zakupki.sqlite3')
regions = db[:regions]

unless regions.count
  system("ruby db/schema.rb")
  Region.regions
end

regions.each { |region| puts "number: #{region[:id]} name: #{region[:name]}" }

puts "Введите номер региона"
region_user_input =  $stdin.gets.chomp

puts "Введите дату пример: 21-12-2020"
date_user_input =  $stdin.gets.chomp
date = Date.parse(date_user_input)
previous_day = (date -=1).strftime("%Y%m%d")
desired_date = Date.parse(date_user_input).strftime("%Y%m%d")

ZipList.get_zip_list(regions, region_user_input, previous_day, desired_date)
zip_list = Dir["./zip_files/*.zip"]

zip_list.each do |file|
  ExtractZip.get_xml(file)
end

xml_list = Dir["./xml_files/*.xml"]

xml_list.delete_if do |f|
  f.include?("contractAvailableForElAct") ||
  f.include?("contractProcedure_")
end

OpenXml.get_contract_list

xml_list.reject{|i| File.directory?(i) }.each{ |i| File.delete(i) }
zip_list.reject{|i| File.directory?(i) }.each{ |i| File.delete(i) }
