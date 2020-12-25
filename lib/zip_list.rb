require 'net/ftp'
require 'fileutils'

class ZipList
  def self.get_zip_list(regions, region_user_input, previous_day, desired_date)
    regions.each { |reg| @region = reg[:name] if
                   reg[:id] == region_user_input.to_i }

    ftp = Net::FTP.new('ftp.zakupki.gov.ru')
    ftp.login 'free', 'free'
    ftp.chdir("/fcs_regions/#{@region}/contracts/currMonth/")
    file_list = ftp.nlst("*.zip").map { |c| c if c.include?("#{previous_day}00_#{desired_date}") }.reject { |e| e.to_s.empty? }

    remotedir = '/zip_files/'

    file_list.each do |file|
      localdir = File.join(remotedir,file)
      localdir = localdir[1..-1] if localdir[0]="/"
      FileUtils.mkdir_p(File.dirname(localdir))
      ftp.getbinaryfile(file, localdir, 1024)
    end

    ftp.close
  end
end
