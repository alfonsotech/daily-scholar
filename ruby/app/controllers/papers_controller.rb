class PapersController < ApplicationController
  def read
    @paper = Paper.find(params[:id])
  end

  def save
  end

  def star
  end

  def download
  end
end
