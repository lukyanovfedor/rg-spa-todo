def sign_in_as(user)
  visit('/#/auth')

  within '.login-form' do
    fill_in 'email', with: user.email
    fill_in 'password', with: user.password
    find('button').trigger('click')
  end
end