class Receipt < ActiveRecord::Base
  attr_accessible :image, :store_id, :store_location_id, :user_id

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }

end
