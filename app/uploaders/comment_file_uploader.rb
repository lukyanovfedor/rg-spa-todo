class CommentFileUploader < CarrierWave::Uploader::Base
  FILES_WHITELIST = %w(pdf txt)

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    FILES_WHITELIST
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  private

  def secure_token
    name = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(name) || model.instance_variable_set(name, SecureRandom.uuid)
  end
end
