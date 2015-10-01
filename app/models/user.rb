class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :rememberable, :omniauthable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :projects, dependent: :destroy

  mount_uploader :image, UserImageUploader

  validates :first_name, :last_name, presence: true
end
