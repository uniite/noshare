class PhotosController < ApplicationController

  before_action :find_photo, only: [:show, :edit, :update, :remove_tag, :download, :destroy]


  def index
    #@photos = Photo.all
    @photos_by_month = (Photo.all.order(:taken_at) * 4).group_by { |p| p.taken_at.beginning_of_month }
  end

  def new
    @photo = Photo.new
  end

  def create
    if params[:data_uri]
      @photo = Photo.new
      @photo.file = params[:data_uri]
    else
      @photo = Photo.new(photo_params)
    end
    if @photo.save!
      redirect_to photos_path
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    #@photo.tag_list.add(photo_params[:new_tags], parse: true)
    if @photo.update(photo_params)
      redirect_to photo_path(@photo)
    else
      render 'edit'
    end
  end

  def remove_tag
    @photo.taggings.where(tag_id: params[:tag]).destroy_all
    redirect_to photo_path(@photo)
  end

  def download
    path = File.join(Rails.root, 'public', @photo.file.url(:original, timestamp: false))
    send_file path, disposition: 'attachment', filename: @photo.file_file_name
  end

  def destroy
  end

private
  def find_photo
    @photo = Photo.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:file, :new_tags, :tag_list)
  end

end
