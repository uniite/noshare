collection @photos

attributes :id, :file_content_type, :file_file_size

node :taken_at do |photo|
  photo.taken_at.to_i
end

node :thumb_url do |photo|
  photo.file.url(:thumb)
end

node :url do |photo|
  photo_path(photo)
end
