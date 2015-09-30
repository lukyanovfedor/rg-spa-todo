FactoryGirl.define do
  factory :attachment do
    file do
      path = File.join(Rails.root, '/spec/fixtures/picasso.jpg')
      Rack::Test::UploadedFile.new(File.open(path))
    end
  end

end
