# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  test 'a message is shown when there are no Articles' do
    visit root_path
    assert_title 'Articles'
    assert_text 'There are no Articles just yet.'
  end

  test 'Article can be created' do
    visit root_path
    click_on 'New Article'
    assert_title 'New Article'

    fill_in 'Title', with: 'My title'
    fill_in 'Body', with: 'My long body'
    click_on 'Create'

    assert_text 'Article was successfully created.'
    assert_title 'My title'
    assert_text 'My long body'
  end

  test 'validation errors are shown' do
    visit root_path
    click_on 'New Article'
    click_on 'Create'

    assert_text "Title can't be blank"
    assert_text "Body can't be blank"
    assert_text 'Body is too short (minimum is 10 characters)'
  end

  test 'previously entered data is shown' do
    visit root_path
    click_on 'New Article'
    fill_in 'Body', with: 'Short'
    click_on 'Create'

    assert_text 'Body is too short (minimum is 10 characters)'
    assert_field 'Body', with: 'Short'
  end

  test 'new Article is listed in the index page' do
    visit root_path
    click_on 'New Article'
    fill_in 'Title', with: 'My title'
    fill_in 'Body', with: 'My long body'
    click_on 'Create'
    click_on 'Back'

    assert_link 'My title'
    assert_text 'My long body'
  end

  test 'Article can be edited' do
    visit root_path
    click_on 'New Article'
    fill_in 'Title', with: 'My title'
    fill_in 'Body', with: 'My long body'
    click_on 'Create'
    click_on 'Edit'

    assert_title 'Edit Article'

    assert_field 'Title', with: 'My title'
    assert_field 'Body', with: 'My long body'

    fill_in 'Title', with: 'Edited title'
    fill_in 'Body', with: 'Edited body'
    click_on 'Update'

    assert_text 'Article was successfully updated.'
    assert_title 'Edited title'
    assert_text 'Edited body'
  end

  test 'validation errors are shown when editing Article' do
    visit root_path
    click_on 'New Article'
    fill_in 'Title', with: 'My title'
    fill_in 'Body', with: 'My long body'
    click_on 'Create'
    click_on 'Edit'

    fill_in 'Title', with: ''
    fill_in 'Body', with: 'Short'
    click_on 'Update'

    assert_text "Title can't be blank"
    assert_text 'Body is too short (minimum is 10 characters)'
    assert_field 'Title', with: ''
    assert_field 'Body', with: 'Short'
  end

  test 'Article can be deleted' do
    visit root_path
    click_on 'New Article'
    fill_in 'Title', with: 'My title'
    fill_in 'Body', with: 'My long body'
    click_on 'Create'
    click_on 'Destroy'

    assert_text 'Article was successfully destroyed'
    assert_text 'There are no Articles just yet.'
  end
end
