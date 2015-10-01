require 'rails_helper'

RSpec.feature "Auths", type: :feature, js: true do
  scenario 'An client can register' do
    user_params = FactoryGirl.attributes_for(:user)

    visit('/#/auth')

    within '.register-form' do
      fill_in 'first_name', with: user_params[:first_name]
      fill_in 'last_name', with: user_params[:last_name]
      fill_in 'email', with: user_params[:email]
      fill_in 'password', with: user_params[:password]
      fill_in 'password_confirmation', with: user_params[:password]
      find('button').trigger('click')
    end

    expect(page).not_to have_content('Register')
  end

  scenario 'An client can sign in' do
    user = FactoryGirl.create(:user)

    visit('/#/auth')

    within '.login-form' do
      fill_in 'email', with: user.email
      fill_in 'password', with: user.password
      find('button').trigger('click')
    end

    expect(page).not_to have_content('Sign in')
  end

  scenario 'An client can sign in' do
    user = FactoryGirl.create(:user)
    sign_in_as(user)

    find('.sign-out-link').trigger('click')

    expect(page).to have_content('Register')
  end
end
