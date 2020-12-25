require 'zip'

class ExtractZip
  def self.get_xml(file)
    destination = "./xml_files/"
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
end
