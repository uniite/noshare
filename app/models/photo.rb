class Photo < ActiveRecord::Base

  attr_accessor :new_tags

  THUMB_SIZE = 50
  MEDIUM_SIZE = 200
  LARGE_SIZE = 2048
  THUMB_TYPE = :jpg

  has_attached_file :file,
                    styles: {
                      thumb: ["#{THUMB_SIZE}x#{THUMB_SIZE}#", THUMB_TYPE],
                      medium: ["#{MEDIUM_SIZE}x#{MEDIUM_SIZE}#", :jpg],
                      large: ["#{LARGE_SIZE}x#{LARGE_SIZE}>", :jpg],
                      large_webp: ["#{LARGE_SIZE}x#{LARGE_SIZE}>", :webp],
                    },
                    convert_options: {
                      thumb: '-quality 90 -interlace Plane',
                      medium: '-quality 85 -interlace Plane',
                      large: '-quality 85',
                      large_webp: '-quality 85 -define webp:method=6',
                    },
                    default_url: '/images/:style/missing.png',
                    url: '/photos/:hash.:extension',
                    hash_secret: ENV['PHOTO_HASH_SECRET'],
                    # Strip EXIF data from scaled images
                    convert_options: { all: '-strip' }

  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/
  validates_attachment_presence :file
  process_in_background :file
  after_post_process :parse_exif
  after_post_process :update_couch

  acts_as_taggable


  # Parses EXIF data out of the photo and stores it in the database
  def parse_exif
    exif = EXIFR::JPEG.new(file.queued_for_write[:original].path)
    return if exif.nil? or not exif.exif?
    self.taken_at = exif.date_time
  rescue
    false
  end

  def update_couch
    return
    hash = photo_hash
    begin
      doc = couch.get(doc_id).body
      hash.merge!(_rev: doc['_rev'])
    rescue Faraday::Error::ResourceNotFound
    end
    couch.put(doc_id, hash)
  end

  def photo_hash
    hash = Rabl::Renderer.new('photos/index.json', self, :view_path => 'app/views', :format => 'hash').render
    hash.delete(:id)
    hash
  end

  def doc_id
    id.to_s
  end

  def couch
    @couch ||= Faraday.new(:url => 'http://127.0.0.1:5984/noshare_dev') do |conn|
      conn.request :json
      conn.response :json
      conn.response :logger                  # log requests to STDOUT
      conn.response :raise_error
      conn.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def thumb_data
    path = File.join(Rails.root, 'public', file.url(:thumb, false))
    data = Base64.strict_encode64(File.binread(path))
    "data:image/#{THUMB_TYPE};base64,#{data}"
  end

  def timestamp
    taken_at || created_at
  end

end