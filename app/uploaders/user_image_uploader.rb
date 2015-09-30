class UserImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  FILES_WHITELIST = %w(png jpg gif)

  storage :file
  process resize_to_fill: [50, 50]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    FILES_WHITELIST
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def default_url
    "/files/fallback/#{model.class.to_s.underscore}/" + [version_name, 'default.jpg'].compact.join('_')
  end

  private

  def secure_token
    name = :"@file_secure_token"
    model.instance_variable_get(name) || model.instance_variable_set(name, SecureRandom.uuid)
  end
end
