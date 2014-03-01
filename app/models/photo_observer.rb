class PhotoObserver < ActiveRecord::Observer

  observe :photo, ActsAsTaggableOn::Tagging

  def after_save(record)
    create_revision(record)
  end

  def after_destroy(record)
    create_revision(record)
  end

  def create_revision(record)
    Revision.create!(record_id: record.id, record_type: record.class.to_s)
  end

end
