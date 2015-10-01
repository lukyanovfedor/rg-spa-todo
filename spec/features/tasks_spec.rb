require 'rails_helper'

RSpec.feature "Tasks", type: :feature, js: true do
  given!(:user) { FactoryGirl.create(:user) }
  given!(:project) { FactoryGirl.create(:project, user: user, title: 'Hello world') }

  scenario 'An client can create task' do
    sign_in_as(user)

    within '.add-task' do
      fill_in 'title', with: 'Buy milk'
      click_button 'Add new task'
    end

    expect(page).to have_content('Buy milk')
  end

  scenario 'An client can update task' do
    FactoryGirl.create(:task, project: project, title: 'Buy milk')
    sign_in_as(user)

    find('.task-link').trigger('click')
    find('.main.task-card .edit-button').trigger('click')

    within '.edit-mode-directive' do
      fill_in 'title', with: 'relax dude'
      find('.edit-mode-update-button').trigger('click')
    end

    expect(page).to have_content('relax dude')
  end

  scenario 'An client can remove task' do
    FactoryGirl.create(:task, project: project, title: 'Buy milk')
    sign_in_as(user)

    find('.task-link').trigger('click')
    find('.main.task-card .edit-button').trigger('click')

    within '.edit-mode-directive' do
      find('.edit-mode-destroy-button').trigger('click')
    end

    expect(page).not_to have_content('Buy milk')
  end
end
