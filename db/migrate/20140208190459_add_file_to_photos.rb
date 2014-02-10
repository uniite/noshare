class AddFileToPhotos < ActiveRecord::Migration
  def change
    add_attachment :photos, :file
  end
end
