# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'json'
require 'csv'

require 'byebug'

url = "https://vovk.com/ua/sales/"
html = open(url)
doc = Nokogiri::HTML(html)

results = []
doc.css('.product__body-inner').each do |product|
  link = product.css(".product__body-img a").first['href']
  name = product.css(".product__body-img a").css('img').first['alt']
  sale_price = product.css(".product__body-price").first['data-price']
  old_price = product.css(".product__body-price").first['data-price-old']
  currency = product.css(".product__body-price .product__body-price__price .price-new .currency__symbol").text.strip
  sizes = product.css(".product__body-sizes .body-sizes__items .body-sizes__item label").text.split("\n")

  results.push({
    name_of_product: name,
    link_of_product: link,
    sale_price: sale_price,
    old_price: old_price,
    currency: currency,
    sizes: sizes.map(&:strip).reject(&:empty?)
  })
end

CSV.open('new_scubber.csv', 'w') do |csv|
  csv << ["name", "link", "sale price", "old price", 'currency', 'sizes']
  results.each { |result| csv << result.values  }
end

