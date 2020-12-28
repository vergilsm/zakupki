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

destination = "./xml_files/"
zip_list = Dir["./zip_files/*.zip"]

zip_list.each do |zip_file|
  extract_zip(zip_file, destination)
end
