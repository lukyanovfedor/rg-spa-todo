class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :rememberable, :omniauthable

  include DeviseTokenAuth::Concerns::User

  has_many :projects, dependent: :destroy

  mount_uploader :image, UserImageUploader

end
