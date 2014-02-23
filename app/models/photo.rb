class Photo < ActiveRecord::Base

  attr_accessor :new_tags

  THUMB_HEIGHT = 100

  has_attached_file :file,
                    styles: { thumb: "#{THUMB_HEIGHT}x#{THUMB_HEIGHT}#" },
                    default_url: '/images/:style/missing.png',
                    url: '/photos/:hash.:extension',
                    :hash_secret => ENV['PHOTO_HASH_SECRET'],
                    # Strip EXIF data from scaled images
                    convert_options: { all: '-strip' }

  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/
  validates_attachment_presence :file
  process_in_background :file
  after_post_process :parse_exif

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