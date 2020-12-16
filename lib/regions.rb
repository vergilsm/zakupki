require 'sequel'

class Region
  def all_regions(regions_on_page)
    db = Sequel.connect('sqlite://db/zakupki.sqlite3')
    regions = db[:regions]

    regions_on_page.each do |region|
      regions.insert(name: region)
    end
  end
end
