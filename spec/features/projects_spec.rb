require 'rails_helper'

RSpec.feature "Projects", type: :feature, js: true do
  given!(:user) { FactoryGirl.create(:user) }

  scenario 'An client can create project' do
    sign_in_as(user)

    find('.new-project-link').trigger('click')

    within '.new-project-modal-form' do
      fill_in 'title', with: 'Hello world'
    end

    find('.create-project-button').trigger('click')

    expect(page).to have_content('Hello world')
  end

  scenario 'An client can update project' do
    FactoryGirl.create(:project, user: user, title: 'Hello world')
    sign_in_as(user)

    find('.edit-button').trigger('click')

    within '.edit-mode-directive' do
      fill_in 'title', with: 'relax dude'
      find('.edit-mode-update-button').trigger('click')
    end

    expect(page).to have_content('relax dude')
  end

  scenario 'An client can remove project' do
    Project.create(user: user, title: "Hi")
    # FactoryGirl.create(:project, user: user, title: 'Hello world')
    sign_in_as(user)

    find('.edit-button').trigger('click')

    within '.edit-mode-directive' do
      find('.edit-mode-destroy-button').trigger('click')
    end

    expect(page).not_to have_content('Hello world')
  end
end
