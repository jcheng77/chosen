class BrandModelTencent < ActiveRecord::Base
  def hd_image_urls
    hd_pics.split('|').map {|p| p.gsub(/\}.*/,'') } if hd_pics
  end
end
