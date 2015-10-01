source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails', '4.2.3'
gem 'pg'
gem 'sprockets'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'haml'
gem 'coffee-rails', '~> 4.1.0'
gem 'jbuilder', '~> 2.0'

gem 'devise_token_auth'
gem 'omniauth-facebook'
gem 'cancancan'
gem 'carrierwave', github:'carrierwaveuploader/carrierwave'
gem 'mini_magick'
gem 'kaminari'
gem 'aasm'
gem 'acts_as_list'
gem 'twitter-bootstrap-rails'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'shoulda-matchers'
end

group :test do
  gem 'database_cleaner', github: 'DatabaseCleaner/database_cleaner', ref: 'b8edac6bd04fb89a267201fa8d47066d511fd9de'
  gem 'fuubar'
  gem 'codeclimate-test-reporter'
  gem 'poltergeist'
end

group :production do
  gem 'rails_12factor'
end

