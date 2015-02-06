require 'nokogiri'
require 'open-uri'

require_relative '../app/models/car/price'
require_relative '../app/models/car/color'
require_relative '../app/models/car/trim'
require_relative '../app/models/car/pic'
require_relative '../app/models/car/model'
require_relative '../app/models/car/brand'
require_relative '../app/models/car/maker'
require_relative '../app/models/brand_model_tencent'

module CarImport

  class Import
    include Car

   def self.bulk_import_cars
     #Tender     .delete_all
     Price .delete_all
     Color .delete_all
     Trim  .delete_all
     Pic   .delete_all
     Model .delete_all
     Maker .delete_all
     Brand .delete_all
     Dir.foreach('data') do |file|
       if file =~ /cars_info/
         import_cars('data/' + file)
       end
     end
     #correct_model_name_and_pics
   end

   def self.import_cars(file='data/cars_info_000')
     data = JSON.parse(File.read(file))
     return if data == []
     brands = {}
     makers = {}
     models = {}
     data.map do |car|
       unless brand = brands[car['@brand']]
         brand = Brand.find_or_create_by(name: car['@brand'])
         brands[car['@brand']] = brand
       end
       unless maker = makers[car['@make']]
         maker = Maker.find_or_create_by(name: car['@make'], brand: brand)
         makers[car['@make']] = maker
       end
       unless car_model = models[car['@model']]
         car_model = Model.find_or_create_by(name: car['@model'], maker: maker)
         models[car['@model']] = car_model
       end
       car_pic = Pic.find_or_create_by(pic_url: car['@icon_link'], model: car_model)
       car_trims = []
       car['@trims'].map do |trim|
         car_trim = Trim.find_or_create_by(name: trim['@trim_name'], model: car_model)
         car_trim.guide_price = trim['@guide_price']
         car_trim.prices << Price.find_or_create_by(offering_date: trim['@price']['@date'], price: trim['@price']['@lowest_price'], trim_id: car_trim.id)
         car_trim.save!
         car_trims << car_trim
       end
       car_colors = []
       car['@colors'].map do |color|
         car_colors << Color.find_or_create_by(name: color['@color_name'], code: color['@color_code'], model: car_model)
       end
       car['@dealers'].map do |dealer|
       end
       car_model.trims = car_trims
       car_model.colors = car_colors
       maker.models << car_model
       brand.makers << maker
     end
   end

   #New added method for parsing json data from auto.qq.com
   def self.fetch_car_basics
    j  = JSON.parse(File.read('data/brand_model_tencent.json'))
    @brand = {}
    self.parse_json(j)
   end

   def self.parse_json(j)
     if j.is_a?(Array)
       j.each do |a|
         parse_json(a)
       end
     else
       j.each do |k,v|
         if v.is_a?(Array)
           parse_json(v)
         else
           #correct the wrong name made by the stupid tencent coder
           @brand.merge!( k == "serialLowPirce" ? {"serial_low_price" => v} : {k.underscore => v})
           #serialCompetion should be the last element of a model
           if k == "serialCompetion"
             #puts "-----------" + @brand.to_s + "\n"
             BrandModelTencent.create!(@brand)
           end
         end
       end
     end
   end


   def self.fetch_hd_pics_for_model_id(sid)
     doc = Nokogiri::HTML.parse(open("http://cgi.data.auto.qq.com/php/index.php?mod=getmodelpicinfo&serialID=#{sid}&modelID=&colorID=&tagID=25"))
     str = doc.children.text

     img_arr = str.scan(/sOriImgUrl.*?jpg/)
     img_urls = img_arr.map { |i| i.match(/\/.*jpg/).to_s.gsub('\\','')}
     img_url_array = img_urls.first(5).map do |u|
          if (u =~ /car_/).nil?
            'http://img1.gtimg.com/datalib_img/' + u.to_s
          end
        end
     b = BrandModelTencent.find_by_serial_id(sid)
     b.update(hd_pics: img_url_array.join('|'))
     b.save
   end


  end

end
