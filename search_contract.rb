require 'sequel'
require 'net/ftp'
require 'fileutils'
require 'zip'
require 'nokogiri'

DB = Sequel.connect('sqlite://db/zakupki.sqlite3')
@ftp = Net::FTP.new('ftp.zakupki.gov.ru')
@ftp.login 'free', 'free'

def db_schema
  DB.create_table? :regions do
    primary_key :id
    String :name
  end
end

db_schema
@regions = DB[:regions]

def list_region
  @ftp.chdir('/fcs_regions')
  files = @ftp.list.first(88)
  all_regions = files.map { |reg| reg.split(" ").last }
  ftp_regions = all_regions.reject { |reg| reg == "ERUZ" || reg == "PG-PZ" }

  ftp_regions.each do |region|
    @regions.insert(name: region)
  end
end

list_region if @regions.empty?

def get_list_zip(date_user_input, region_user_input, desired_date)
  region = nil
  current_month = Time.now.strftime("%m")

  @regions.each do |reg|
    region = reg[:name] if reg[:id] == region_user_input.to_i
  end

  if current_month == Date.parse(date_user_input).strftime("%m")
    @ftp.chdir("/fcs_regions/#{region}/contracts/currMonth/")
  else
    @ftp.chdir("/fcs_regions/#{region}/contracts/")
  end

  list_file = @ftp.nlst("*.zip").select do |zip_file|
    desired_date == Date.parse(@ftp.mtime(zip_file).to_s).strftime("%d%m%Y")
  end.reject { |file| file.to_s.empty? }

  list_file.each do |file|
    localdir = File.join("tmp/#{date_user_input}/contracts/#{region_user_input}/zip/", file)
    FileUtils.mkdir_p(File.dirname(localdir))
    @ftp.getbinaryfile(file, localdir, 1024)
  end
end

def get_list_xml(file, date_user_input, region_user_input)
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

def get_list_contract(list_xml)
  list_xml.each do |file|
    doc = Nokogiri::XML(File.open(file))
    doc.css('//regNum').each do |num|
      puts num.text if num.text.scan(/\d/).length >= 19
    end
  end
end

@regions.each { |region| puts "number: #{region[:id]} name: #{region[:name]}" }

puts "Введите номер региона"
region_user_input = STDIN.gets.chomp

puts "Введите дату пример: 02-02-2021"
date_user_input = STDIN.gets.chomp
desired_date = Date.parse(date_user_input).strftime("%d%m%Y")

get_list_zip(date_user_input, region_user_input, desired_date)
list_zip = Dir["tmp/#{date_user_input}/contracts/#{region_user_input}/zip/*.zip"]

list_zip.each do |file|
  get_list_xml(file, date_user_input, region_user_input)
end

list_xml = Dir["tmp/#{date_user_input}/contracts/#{region_user_input}/xml/*.xml"]
list_xml.delete_if { |f| f.include?("contractProcedure_") }
list_xml.delete_if { |f| f.include?("contractAvailableForElAct") }

get_list_contract(list_xml)

#list_zip.reject{|file| File.directory?(file) }.each{ |f| File.delete(f) }
#list_xml = Dir["tmp/#{date_user_input}/contracts/#{region_user_input}/xml/*.xml"]
#list_xml.reject{|file| File.directory?(file) }.each{ |f| File.delete(f) }
