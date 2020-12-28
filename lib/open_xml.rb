require 'open-uri'
require 'nokogiri'

class OpenXml
  def self.get_contract_list
    xml_files = Dir["xml_files/*.xml"]
    xml_files.each do |file|
      response = URI.open(file.to_s).read
      doc = Nokogiri::XML(response)
      doc.css('//regNum').each do |num|
        puts num.text if num.text.scan(/\d/).length >= 19
      end
    end
  end
end
