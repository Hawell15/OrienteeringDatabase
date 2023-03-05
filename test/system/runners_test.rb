require "application_system_test_case"

class RunnersTest < ApplicationSystemTestCase
  setup do
    @runner = runners(:one)
  end

  test "visiting the index" do
    visit runners_url
    assert_selector "h1", text: "Runners"
  end

  test "creating a Runner" do
    visit runners_url
    click_on "New Runner"

    fill_in "Best category", with: @runner.best_category
    fill_in "Category", with: @runner.category
    fill_in "Category valid", with: @runner.category_valid
    fill_in "Checksum", with: @runner.checksum
    fill_in "Club", with: @runner.club
    fill_in "Dob", with: @runner.dob
    fill_in "Forrest wre rang", with: @runner.forrest_wre_rang
    fill_in "Gender", with: @runner.gender
    fill_in "Runner name", with: @runner.runner_name
    fill_in "Sprint wre rang", with: @runner.sprint_wre_rang
    fill_in "Surname", with: @runner.surname
    fill_in "Wre", with: @runner.wre_id
    click_on "Create Runner"

    assert_text "Runner was successfully created"
    click_on "Back"
  end

  test "updating a Runner" do
    visit runners_url
    click_on "Edit", match: :first

    fill_in "Best category", with: @runner.best_category
    fill_in "Category", with: @runner.category
    fill_in "Category valid", with: @runner.category_valid
    fill_in "Checksum", with: @runner.checksum
    fill_in "Club", with: @runner.club
    fill_in "Dob", with: @runner.dob
    fill_in "Forrest wre rang", with: @runner.forrest_wre_rang
    fill_in "Gender", with: @runner.gender
    fill_in "Runner name", with: @runner.runner_name
    fill_in "Sprint wre rang", with: @runner.sprint_wre_rang
    fill_in "Surname", with: @runner.surname
    fill_in "Wre", with: @runner.wre_id
    click_on "Update Runner"

    assert_text "Runner was successfully updated"
    click_on "Back"
  end

  test "destroying a Runner" do
    visit runners_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Runner was successfully destroyed"
  end
end
