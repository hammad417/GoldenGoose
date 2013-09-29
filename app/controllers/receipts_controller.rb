class ReceiptsController < ApplicationController

  before_filter :authenticate_user!

  api :POST, '/users/:users_id/receipts/upload_receipt_image', 'Create a new receipt with image.'
  error :code => 401, :desc => "Unauthorized"
  error :code => 404, :desc => "File not present"
  description "Create new receipt with image."
  param :auth_token, String, :desc => 'The auth token.', :required => true
  param :image, ActionDispatch::Http::UploadedFile, :desc => 'The receipts image.', :required => true
  param :user_id, String, :desc => 'The user ID.', :required => true
  param :store_id, String, :desc => 'The shop ID.'
  param :store_location_id, String, :desc => 'The shop location ID.'
  example '{curl -i -F "image=@facebook.png;type=image/png" http://api.shopvizr.com/api/users/1/recepits/upload_receipt_image.json}'
  def upload_receipt_image
    unless params[:image].blank?
      @receipt = Receipt.new
      @receipt.user_id = params[:user_id]
      @receipt.store_id = params[:store_id]
      @receipt.store_location_id = params[:store_location_id]
      @receipt.image = params[:image]
      if @receipt.save
        return render :json => {"receipt" => @receipt.as_json, "image_url" => @receipt.image.url}, :status => 200
      else
        return render :json => {'error' => 'Error in saving receipt'}.as_json, :status => 424
      end
    else
      return render :json => {'error' => 'File not present'}.as_json, :status => 404
    end
  end

end
