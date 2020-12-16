class Url
  def self.base_url
    "https://zakupki.gov.ru/epz/opendata/search/results.html?searchString=&morphology=on&savedSearchSettingsIdHidden=&dataset44IdHidden=5%2C&dataset44IdNameHidden=%7B%225%22%3A%22%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F+%D0%BE+%D0%BA%D0%BE%D0%BD%D1%82%D1%80%D0%B0%D0%BA%D1%82%D0%B0%D1%85%22+%7D&dataset223IdHidden=&dataset223IdNameHidden=%7B%7D&dataset615IdHidden=&dataset615IdNameHidden=%7B%7D&customerPlace=&customerPlaceCodes=&pageNumber=1&sortDirection=false&recordsPerPage=_50&showLotsInfoHidden=false"
  end

  def self.base_url2
    "https://zakupki.gov.ru/epz/opendata/search/results.html?searchString=&morphology=on&savedSearchSettingsIdHidden=&dataset44IdHidden=5%2C&dataset44IdNameHidden=%7B%225%22%3A%22%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F+%D0%BE+%D0%BA%D0%BE%D0%BD%D1%82%D1%80%D0%B0%D0%BA%D1%82%D0%B0%D1%85%22+%7D&dataset223IdHidden=&dataset223IdNameHidden=%7B%7D&dataset615IdHidden=&dataset615IdNameHidden=%7B%7D&customerPlace=&customerPlaceCodes=&pageNumber=2&sortDirection=false&recordsPerPage=_50&showLotsInfoHidden=false"
  end

  def self.user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
  end

  def self.doc(base_url, user_agent)
    Nokogiri::HTML(open(base_url, 'User-Agent' => user_agent,
                            'read_timeout' => '10' ), nil, "UTF-8")
  end

  def self.regions_on_page(doc)
    doc.xpath("//div[@id='search-registry-entrys-block']//div[@class='text-break registry-entry__header-mid__number']/a/text()").map { |x| x.to_s.delete("\n").strip }
  end
end
