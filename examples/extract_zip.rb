require 'zip'

def extract_zip(file, destination)
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

zip_file = "contract_Moskva_2020122000_2020122100_001.xml.zip"
destination = "./xml_files/"

extract_zip(zip_file, destination)
