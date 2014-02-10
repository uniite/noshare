class TagsController < ApplicationController

  before_action :find_tag, only: [:show]


  def index
    @tags = ActsAsTaggableOn::Tag.all
  end

  def show
    @photos = Photo.tagged_with(@tag)
  end

  private
    def find_tag
      @tag = ActsAsTaggableOn::Tag.find(params[:id])
    end

end