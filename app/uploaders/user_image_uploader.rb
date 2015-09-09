class UserImageUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    "/files/fallback/#{model.class.to_s.underscore}/" +
      [version_name, 'default.jpg'].compact.join('_')
  end

end
