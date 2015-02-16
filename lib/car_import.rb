#encoding: utf-8

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

   def self.generate_hd_pics_json
      brand_array = []
      BrandModelTencent.all.each do |b|
         brand = { "serialID" => b.serial_id }
         img_urls = []
         b.hd_pics.split('|').each do |ul|
           img_urls << ul
         end
         brand.merge!({"hd_pics" => img_urls})
         brand_array << brand
      end
      puts JSON.generate(brand_array)
   end

   def self.generate_all_info
      brand_array = []
      BrandModelTencent.all.each do |b|
        brand = b.attributes
         img_urls = []
         similar_cars = []
         comments = []
         unless b.hd_pics.nil?
         b.hd_pics.split('|').each do |ul|
           img_urls << ul
         end
         end
         b.serial_competion.split(';').each do |sc|
             similar_cars << ["serial_id","serial_name"].zip(sc.split('|')).to_h
         end
         comments = b.good_comments.split('|') unless b.good_comments.nil?
         comments +=  b.bad_comments.split('|') unless b.bad_comments.nil?
         brand.merge!({"hd_pics" => img_urls})
         brand.merge!({"serial_competion" => similar_cars })
         brand.merge!({"labels" => comments})
         brand_array << brand
      end
      puts JSON.generate(brand_array)
   end

   def self.migrate_tencent_data
     Vehicle.delete_all
     BrandModelTencent.all.each do |b|
       v = Vehicle.new({brand: b.brand_name , model: b.serial_name, lowest_price: b.serial_low_price, highest_price:  b.serial_high_price })
       if b.hd_image_urls
          b.hd_image_urls.each do |u|
            v.images << Image.new(url: u)
          end
       end
       v.save
     end
   end

   def self.generate_xcar_brand_serial_json(file)
     XcarShortComments.delete_all
     @xcar_serial_hash = {}
     @xcar_brand_hash = {}
     data = File.read(file)
     data.split(';').each_with_index do |line, i|
     if i == 0
       parse_brand_line(line)
     else
       brand_id , serial_list_str = parse_line_str(line)
       parse_array_str(serial_list_str,brand_id)
     end
    end
   puts JSON.generate(@xcar_serial_hash)
   end

   def self.parse_array_str(line,brand_id)
     unless line.nil?
      id_name_arr = line.split(',')
      id_name_arr.each_with_index do |s,j|
         next if j%2 == 0
         id, name = id_name_arr[j-1] , id_name_arr[j]
         @xcar_serial_hash.merge!({id => name})
         x = XcarShortComments.new({brand_id: brand_id, brand_name: @xcar_brand_hash[brand_id], serial_id: id, serial_name: name})
         x.save
       end
     end
   end

   def self.parse_brand_line(line)
    id_name_arr = line.split(',')
     id_name_arr.each_with_index do |s,j|
      next if j%2 == 0
      id, name = id_name_arr[j-1] , id_name_arr[j]
      @xcar_brand_hash.merge!({id => name.split(' ').last })
     end
   end

   def self.parse_line_str(line)
      l = line.split("'")
      return l[1] , l[3]
   end

   def self.fetch_xcar_comments(good = 2)
     XcarShortComments.where(good_comments: nil).to_a.each do |x|
       fetch_xcar_comment_for_sid(x.serial_id)
     end
   end

   def self.fetch_xcar_comment_for_sid(sid)
     [1,2].each do |type|
       fetch_xcar_comment_for_sid_per_type(sid,type)
     end
   end


   def self.fetch_xcar_comment_for_sid_per_type(sid,type)
     url = ['http://newcar.xcar.com.cn/', sid, '/review/',type,'/0.htm'].join
     comments = []
     begin
     doc = Nokogiri::HTML.parse(open(url))
     doc.css('div.review_comments_dl dt a').each do |a|
       comments << remove_unneeded_words(a.text.split(' ').last) if a["href"] =~ /http:.*/
     end
     rescue Exception => e
       puts e.to_s
     end
     unless comments.empty?
     x = XcarShortComments.find_by_serial_id(sid)
     if type == 1
     x.update(good_comments: comments.join('|'))
     else
     x.update(short_comments: comments.join('|'))
     end
     end
   end

   def self.remove_unneeded_words(comment)
     comment.gsub(/\d\.\dT/,'').gsub(/自动/,'') 
   end

   def self.integrate_xcar_comments_to_tencent_data
     BrandModelTencent.all.each do |b|
       XcarShortComments.all.each do |x|
         if b.serial_name == x.serial_name or b.serial_name.gsub('）','').gsub('（','') == x.serial_name.gsub('(','').gsub(')','') or b.serial_name.match(x.serial_name) or x.serial_name.match(b.serial_name)
            puts "T: #{b.serial_name} X: #{x.serial_name}"
            b.good_comments = x.good_comments
            b.bad_comments = x.short_comments
            x.tencent_sid = b.serial_id
            x.hd_pic = b.hd_pics.first unless b.hd_pics.nil?
         end
         b.save
         x.save
       end
     end
   end


  def self.get_first_qq_pic_for_xcar_sid
    XcarShortComments.all.each do |x|
      b = BrandModelTencent.find_by_serial_id(x.tencent_sid)
      if b
        x.hd_pic = b.hd_pics.split('|').first if b.hd_pics
        x.save
      end
    end
  end

  end

  
end
