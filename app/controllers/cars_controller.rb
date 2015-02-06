class CarsController < ApplicationController


  def brands
    @car_brands = Car::Brand.all
  end


  def list
    @car_brands = Car::Brand.includes(:makers, :trims, :shops, models: [:pics, :colors]).all

    @cars = { 'brands' => [] }

    @car_brands.each do |car_brand|

      brand = { id: car_brand.id, 'name' => car_brand.name, 'logo_url' => car_brand.logo_url, 'makers' => [] }

      car_brand.makers.each  do |car_maker|

        maker = { id: car_maker.id, 'name' => car_maker.name, 'models' => [] }

        car_maker.models.each do |car_model|

          next if maker['models'].index { |model| model['name'] == car_model.name }

          model = { id: car_model.id, 'name' => car_model.name, 'pic_url' => car_model.pics[0].pic_url, 'trims' => [], 'colors' => [], 'shops' => []}

          car_model.trims.each do |car_trim|
            lowest_price = Car::Price.where(:trim_id => car_trim.id).first #.order('offering_date desc').first
            model['trims'] << { 'id' => car_trim.id, 'name' => car_trim.name, 'guide_price' => car_trim.guide_price, 'lowest_price' => lowest_price == nil ? -1 : lowest_price.price }
          end

          car_model.colors.each do |car_color|
            model['colors'] << { id: car_color.id, 'name' => car_color.name, 'code' => car_color.code }
          end

          car_model.shops.each do |shop|
           model['shops'] << { id: shop.id, name: shop.name, address: shop.address } 
          end

          maker['models'] << model
        end
        brand['makers'] << maker
      end
      @cars['brands'] << brand
    end

    respond_to do |format|
      format.html { render index.html.erb }
      format.xml  { render xml: @cars }
      format.json { render json: @cars }
    end
  end

  def trims
    @models = Car::Model.find_by(id: params['model_id'])
    @trims = @models.trims
    @trims.each do |car_trim|
      car_trim.update(view_count: rand(10)) unless car_trim.view_count.present?
    end
    respond_to do |format|
      #format.html index.html.erb
      format.xml  { render xml: @trims }
      format.json { render json: @trims }
    end
  end

  def self.bulk_import_cars
    #Tender     .delete_all
    Bargain    .delete_all
    Deal       .delete_all
    Shop       .delete_all
    Car::Price .delete_all
    Car::Color .delete_all
    Car::Trim  .delete_all
    Car::Pic   .delete_all
    Car::Model .delete_all
    Car::Maker .delete_all
    Car::Brand .delete_all
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
        brand = Car::Brand.find_or_create_by(name: car['@brand'])
        brands[car['@brand']] = brand
      end
      unless maker = makers[car['@make']]
        maker = Car::Maker.find_or_create_by(name: car['@make'], brand: brand)
        makers[car['@make']] = maker
      end
      unless car_model = models[car['@model']]
        car_model = Car::Model.find_or_create_by(name: car['@model'], maker: maker)
        models[car['@model']] = car_model
      end
      car_pic = Car::Pic.find_or_create_by(pic_url: car['@icon_link'], model: car_model)
      car_trims = []
      car['@trims'].map do |trim|
        car_trim = Car::Trim.find_or_create_by(name: trim['@trim_name'], model: car_model)
        car_trim.guide_price = trim['@guide_price']
        car_trim.prices << Car::Price.find_or_create_by(offering_date: trim['@price']['@date'], price: trim['@price']['@lowest_price'], trim_id: car_trim.id)
        car_trim.save!
        car_trims << car_trim
      end
      car_colors = []
      car['@colors'].map do |color|
        car_colors << Car::Color.find_or_create_by(name: color['@color_name'], code: color['@color_code'], model: car_model)
      end
      car_shops = []
      car['@dealers'].map do |dealer|
        car_shop = Shop.find_or_create_by(name: dealer['@name'])
        car_shop.address = dealer['@address']
        car_shop.save!
        car_shops << car_shop
      end
      car_model.pics << car_pic
      car_model.trims = car_trims
      car_model.colors = car_colors
      car_model.shops = car_shops
      maker.models << car_model
      brand.makers << maker
    end
  end

  def self.correct_model_name_and_pics(source = 'data/cars_pics_urls')
    str = ''
    pic_data = JSON.parse(File.read(source))

    @car_brands = Car::Brand.includes(:makers, models: [:pics]).all

    @car_brands.each do |car_brand|

      car_brand.makers.each  do |car_maker|

        car_maker.models.each do |car_model|
          others = car_model.name[/([\(|（].+[\)|）])/u,1]
          if others != nil
            if others.include? "进口"
              car_model.name.delete!(others) 
              car_model.name += "(进口)"
            else
              car_model.name.delete!(others)
            end
          end
          car_model.save 
          if pic_data['Cars'].include? car_brand.name
            pic_data['Cars'][car_brand.name].keys.each do |pic_data_model_name|
              if pic_data_model_name.include? car_model.name
                car_pic = Car::Pic.find_or_create_by(pic_url: pic_data['Cars'][car_brand.name][pic_data_model_name], model: car_model)
                Car::Pic.where(pic_url: nil, model: car_model).delete_all
                Car::Pic.where(pic_url: '', model: car_model).delete_all
              end
            end
          end
          str << "#{car_model.name} : #{car_model.pics[0].pic_url}\n"
        end
      end
    end
    File.open('data/models_without_pic','w+') { |file| file.write(str) }
  end

  def self.change_car_pic_url
    Car::Pic.all.each do |car_pic|
      if car_pic.pic_url!=nil and car_pic.pic_url!=''
        car_pic.pic_url = 'autoalbum/' + car_pic.pic_url[/\d+_\d+\.jpg/] 
        car_pic.save
      end
    end
  end

  def self.associate_brands_with_shops
    @car_brands = Car::Brand.includes(:makers, models: [:shops]).all
    @car_brands.each do |car_brand|
      shops = []
      car_brand.makers.each do |car_maker|
        car_maker.models.collect { |car_model| shops += car_model.shops }
      end
      car_brand.shops = shops
    end    
  end

  def self.add_brand_logo(source='data/car_brand_logo')
    logos = JSON.parse(File.read(source))
    @car_brands = Car::Brand.all
    @car_brands.each do |car_brand|
      if logos.has_key? car_brand.name
        puts logos[car_brand.name][/\d+\.(jpg|JPG|gif)/]
        domain = ''
        puts Rails.env
        case Rails.env
          when 'development'
            domain = 'http://localhost:3000'
          when 'staging'
            domain = 'http://staging.pailixing.com'
          when 'production'
            domain = 'http://www.pailixing.com'
          else
            domain = 'http://www.pailixing.com'
        end
        car_brand.logo_url = domain + '/brandlogo/' + logos[car_brand.name][/\d+\.(jpg|JPG|gif)/]
        car_brand.save!
      end 
    end
  end


end
