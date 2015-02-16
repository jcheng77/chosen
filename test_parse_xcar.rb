require 'json'
@h = {}

def parse_array_str(line)
  unless line.nil?
 id_name_arr = line.split(',')
 id_name_arr.each_with_index do |s,j|
    next if j%2 == 0
    @h.merge!({id_name_arr[j-1] => id_name_arr[j]})
    end
  end
end

def parse_line_str(line)
  l = line.split("'")
  return l[1] , l[3]
end


data = File.read('data/xcar_review.data')
data.split(';').each_with_index do |line, i|
   if i == 0
     brand_list_line = line 
     brand_arr = parse_array_str(brand_list_line)
   else
     brand_id , serial_list_str = parse_line_str(line)
     parse_array_str(serial_list_str)
   end
   puts JSON.generate(@h)
end

