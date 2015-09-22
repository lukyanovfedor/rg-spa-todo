module CommentsHelper
  def file_name(file_path)
    file_path.split('/').last
  end
end