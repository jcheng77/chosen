require 'car_import'

task :generate_xcar_brand_serial_json => :environment do
    CarImport::Import::generate_xcar_brand_serial_json('data/xcar_review.data')
end

task :fetch_xcar_comments => :environment do
    CarImport::Import::fetch_xcar_comments
end

task :migrate_xcar_comments => :environment do
    CarImport::Import::integrate_xcar_comments_to_tencent_data
end

task :get_cover_weixin_msg => :environment do
    CarImport::Import::get_first_qq_pic_for_xcar_sid
end







