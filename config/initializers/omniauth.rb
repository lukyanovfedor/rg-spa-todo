Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '1063444153665624', '011a91ea45b9e05c644b3f0e4b8d7b90', info_fields: 'email, first_name, last_name', secure_image_url: true
end