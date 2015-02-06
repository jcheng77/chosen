require 'car_import'

task :fetch_car_basics => :environment do
    CarImport::Import::fetch_car_basics
end

task :fetch_only_audi_hd_pics => :environment do
  BrandModelTencent.where("brand_id = ?", 2).each do |b|
    CarImport::Import::fetch_hd_pics_for_model_id(b.serial_id)
  end
end
