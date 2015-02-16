require 'car_import'

task :migrate_tencent_data => :environment do
  CarImport::Import::migrate_tencent_data
end
