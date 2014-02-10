class AddFileFingerprintToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :file_fingerprint, :string
  end
end
