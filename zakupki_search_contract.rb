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
desired_date = Date.parse(date_user_input).strftime("%d%m%Y")

ZipList.get_zip_list(regions, region_user_input, desired_date)
zip_list = Dir["./zip_files/*.zip"]

zip_list.each do |file|
  ExtractZip.get_xml_list(file)
end

xml_list = Dir["./xml_files/*.xml"]
xml_list.delete_if { |f| f.include?("contractProcedure_") }
xml_list.delete_if { |f| f.include?("contractProcedure_") }

OpenXml.get_contract_list

zip_list.reject{|i| File.directory?(i) }.each{ |i| File.delete(i) }
xml_list = Dir["./xml_files/*.xml"]
xml_list.reject{|i| File.directory?(i) }.each{ |i| File.delete(i) }
