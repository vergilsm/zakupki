require 'sequel'
require 'net/ftp'

class Region
  def self.regions
    ftp = Net::FTP.new('ftp.zakupki.gov.ru')
    ftp.login 'free', 'free'
    ftp.chdir('/fcs_regions')
    files = ftp.list.first(88)
    all_regions = files.map { |reg| reg.split(" ").last }
    ftp_regions = all_regions.reject { |reg| reg == "ERUZ" }.reject { |reg| reg == "PG-PZ" }

    db = Sequel.connect('sqlite://db/zakupki.sqlite3')
    regions = db[:regions]

    ftp_regions.each do |region|
      regions.insert(name: region)
    end

    ftp.close
  end
end
