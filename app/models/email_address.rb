class EmailAddress < ActiveRecord::Base

  belongs_to :user

  attr_accessible :address, :user_id
  validates :address,  :uniqueness => {:case_sensitive => false}
end
