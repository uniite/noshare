class PhotosController < ApplicationController

  before_action :find_photo, only: [:show, :edit, :update, :remove_tag, :download, :destroy]


  def index
    respond_to do |format|
      format.html do
        @photos_by_month = (Photo.all.order(:taken_at) * 4).group_by { |p| (p.taken_at || p.created_at).beginning_of_month }
      end
      format.json do
        @photos = Photo.all * 8
      end
    end
  end

  def new
    @photo = Photo.new
    render 'upload'
  end

  def create
    if params[:data_uri]
      @photo = Photo.new
      @photo.file = params[:data_uri]
    else
      @photo = Photo.new(photo_params)
    end
    if @photo.save!
      respond_to do |format|
        format.any { redirect_to photos_path }
        format.json do
          render json: {
            files: [
              {
                name: @photo.file_file_name,
                size: @photo.file_file_size,
                size: @photo.file.url,
                thumbnailUrl: @photo.file.url(:thumb),
                deleteUrl: photo_path(@photo),
                deleteType: 'DELETE',
              }
            ]
          }
        end
      end
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
    respond_to do |format|
      format.any { redirect_to photos_path }
      format.json do
        render json: {
          files: [
            {
              @photo.file_file_name => true
            }
          ]
        }
      end
    end
  end

private
  def find_photo
    @photo = Photo.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:file, :new_tags, :tag_list)
  end

end
