object @photo

attributes :id

node :taken_at do |photo|
  photo.timestamp
end

node :thumb_data do |photo|
  photo.thumb_data
end

node :thumb_url do |photo|
  photo.file.url(:thumb, false)
end

node :url do |photo|
  photo.file.url
end

node :tags do |photo|
  photo.tag_list
end
