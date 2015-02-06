json.array!(@vehicles) do |vehicle|
  json.extract! vehicle, :id, :brand, :model, :lowest_price, :highest_price, :image_url
  json.url vehicle_url(vehicle, format: :json)
end
