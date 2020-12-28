require 'net/ftp'
require 'fileutils'
require 'zip'

@region = "Moskva"
desired_date = "20122020"

ftp = Net::FTP.new('ftp.zakupki.gov.ru')
ftp.login 'free', 'free'
ftp.chdir("/fcs_regions/#{@region}/contracts/currMonth/")
file_list = ftp.nlst("*.zip").map { |c| c if
                                    desired_date == Date.
                                    parse(ftp.mtime(c).to_s).
                                    strftime("%d%m%Y")
                                  }.reject { |e| e.to_s.empty? }

puts file_list
puts

file_list.each do |file|
  localdir = File.join('zip_files/', file)
  FileUtils.mkdir_p(File.dirname(localdir))
  zip_file = ftp.getbinaryfile(file, localdir)

  puts file
end

ftp.close
