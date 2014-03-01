class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.integer :record_id
      t.string :record_type
    end
  end
end
