require 'sequel'
require 'net/ftp'
require 'fileutils'
require 'zip'
require 'nokogiri'

DB = Sequel.connect('sqlite://db/zakupki.sqlite3')
ftp = Net::FTP.new('ftp.zakupki.gov.ru')
ftp.login 'free', 'free'

DB.create_table? :regions do
  primary_key :id
  String :name
end

regions = DB[:regions]

if regions.empty?
  ftp.chdir('/fcs_regions')
  files = ftp.list.first(88)
  all_regions = files.map { |reg| reg.split(" ").last }
  ftp_regions = all_regions.reject { |reg| reg == "ERUZ" || reg == "PG-PZ" }

  ftp_regions.each do |region|
    regions.insert(name: region)
  end
end

regions.each { |region| puts "number: #{region[:id]} name: #{region[:name]}" }

puts "Введите номер региона"
region_user_input = STDIN.gets.chomp

puts "Введите дату пример: 02-02-2021"
date_user_input = STDIN.gets.chomp
desired_date = Date.parse(date_user_input).strftime("%d%m%Y")

region = nil
current_month = Time.now.strftime("%m")

regions.each do |reg|
  region = reg[:name] if reg[:id] == region_user_input.to_i
end

if current_month == Date.parse(date_user_input).strftime("%m")
  ftp.chdir("/fcs_regions/#{region}/contracts/currMonth/")
else
  ftp.chdir("/fcs_regions/#{region}/contracts/")
end

list_file = ftp.nlst("*.zip").select do |zip_file|
  desired_date == Date.parse(ftp.mtime(zip_file).to_s).strftime("%d%m%Y")
end.reject { |file| file.to_s.empty? }

list_file.each do |file|
  localdir = File.join("tmp/#{date_user_input}/contracts/#{region_user_input}/zip/", file)
  FileUtils.mkdir_p(File.dirname(localdir))
  ftp.getbinaryfile(file, localdir, 1024)
end

list_zip = Dir["tmp/#{date_user_input}/contracts/#{region_user_input}/zip/*.zip"]

list_zip.each do |file|
  destination = "./tmp/#{date_user_input}/contracts/#{region_user_input}/xml/"
  FileUtils.mkdir_p(destination)

  Zip::File.open(file) do |zip_file|
    zip_file.each do |f|
      if f.name =~ /\w*.xml/
        fpath = File.join(destination, f.name)
        zip_file.extract(f, fpath) unless File.exist?(fpath)
      end
    end
  end
end

all_xml_list = Dir["tmp/#{date_user_input}/contracts/#{region_user_input}/xml/*.xml"]
list_xml = all_xml_list.select { |file| file if file.include?("contractProcedure_")  }

list_xml.each do |file|
  doc = Nokogiri::XML(File.open(file))
  if doc.css("//currentContractStage").text == "ET" &&
     doc.css("//termination reason code").text == "3"
    puts doc.css("//termination docTermination name").text
    puts doc.css("//regNum").text
  end
end

#list_zip.reject{|file| File.directory?(file) }.each{ |f| File.delete(f) }
#list_xml = Dir["tmp/#{date_user_input}/contracts/#{region_user_input}/xml/*.xml"]
#list_xml.reject{|file| File.directory?(file) }.each{ |f| File.delete(f) }
