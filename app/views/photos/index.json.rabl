collection @photos

attributes :id

node :taken_at do |photo|
  (photo.taken_at || photo.created_at).to_i
end

node :thumb_data do |photo|
  path = File.join(Rails.root, 'public', photo.file.url(:thumb, false))
  data = Base64.strict_encode64(File.binread(path))
  "data:#{photo.file_content_type};base64,#{data}"
end

node :thumb_url do |photo|
  photo.file.url(:thumb)
end

node :url do |photo|
  photo.file.url
end

node :tags do |photo|
  photo.tag_list
end
