class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :rememberable, :omniauthable

  include DeviseTokenAuth::Concerns::User


end
