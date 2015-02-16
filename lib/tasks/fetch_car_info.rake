require 'car_import'

task :fetch_car_basics => :environment do
    CarImport::Import::fetch_car_basics
end

task :fetch_only_audi_hd_pics => :environment do
  BrandModelTencent.where("brand_id = ?", 2).each do |b|
    CarImport::Import::fetch_hd_pics_for_model_id(b.serial_id)
  end
end

task :fetch_all_hd_pics => :environment do
  BrandModelTencent.all.each_with_index do |b,i|
    puts "#{i} have been processed!"
    sleep(0.5)
    CarImport::Import::fetch_hd_pics_for_model_id(b.serial_id)
  end
end

task :generate_hd_pics_json => :environment do
    CarImport::Import::generate_hd_pics_json
end

task :generate_all_info => :environment do
    CarImport::Import::generate_all_info
end

task :fetch_car_comments => :environment do
    CarImport::Import::fetch_car_comments_from_xcar
end

