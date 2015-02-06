require 'car_import'

task :init_data  => :environment do
  CarImport::Import::bulk_import_cars
end
