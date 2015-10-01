require 'rails_helper'

RSpec.feature "Comments", type: :feature, js: true do
  given!(:user) { FactoryGirl.create(:user) }
  given!(:project) { FactoryGirl.create(:project, user: user, title: 'Hello world') }
  given!(:task) { FactoryGirl.create(:task, project: project, title: 'Buy milk') }

  scenario 'An client can add comment' do
    sign_in_as(user)

    find('.task-link').trigger('click')
    within '.add-comment' do
      fill_in 'note', with: 'This task is so cool!'
      attach_file('file', "#{Rails.root}/spec/fixtures/picasso.jpg")
      click_button 'Add comment'
    end

    expect(page).to have_content('This task is so cool!')
  end

  scenario 'An client can remove comment attachment' do
    FactoryGirl.create(:comment, task: task, note: 'This task is so cool!')
    sign_in_as(user)

    find('.task-link').trigger('click')
    find('.edit-comment').trigger('click')
    find('.remove-attachment').trigger('click')

    expect(page).to have_content('Attachment deleted.')
  end

  scenario 'An client can update comment' do
    FactoryGirl.create(:comment, task: task, note: 'This task is so cool!')
    sign_in_as(user)

    find('.task-link').trigger('click')
    find('.edit-comment').trigger('click')

    within '.add-comment' do
      fill_in 'note', with: 'Bad comment!'
      click_button 'Edit comment'
    end

    expect(page).to have_content('Bad comment!')
  end

  scenario 'An client can remove comment' do
    FactoryGirl.create(:comment, task: task, note: 'This task is so cool!')
    sign_in_as(user)

    find('.task-link').trigger('click')
    find('.destroy-comment').trigger('click')

    expect(page).not_to have_content('This task is so cool!')
  end
end
