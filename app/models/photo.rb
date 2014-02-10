class Photo < ActiveRecord::Base

  attr_accessor :new_tags

  THUMB_WIDTH = 300

  has_attached_file :file,
                    styles: { large: '1200x1200>', medium: '600x600>', thumb: "#{THUMB_WIDTH}x#{THUMB_WIDTH}#" },
                    default_url: '/images/:style/missing.png',
                    url: '/photos/:hash.:extension',
                    :hash_secret => ENV['PHOTO_HASH_SECRET'],
                    # Strip EXIF data from scaled images
                    convert_options: { all: '-strip' }
  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/

  after_post_process :parse_exif

  validates_attachment_presence :file

  acts_as_taggable


  # Parses EXIF data out of the photo and stores it in the database
  def parse_exif
    exif = EXIFR::JPEG.new(file.queued_for_write[:original].path)
    return if exif.nil? or not exif.exif?
    self.taken_at = exif.date_time
  rescue
    false
  end

end