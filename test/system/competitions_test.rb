require "application_system_test_case"

class CompetitionsTest < ApplicationSystemTestCase
  setup do
    @competition = competitions(:one)
  end

  test "visiting the index" do
    visit competitions_url
    assert_selector "h1", text: "Competitions"
  end

  test "creating a Competition" do
    visit competitions_url
    click_on "New Competition"

    fill_in "Checksum", with: @competition.checksum
    fill_in "Competition name", with: @competition.competition_name
    fill_in "Country", with: @competition.country
    fill_in "Date", with: @competition.date
    fill_in "Location", with: @competition.location
    fill_in "Type", with: @competition.type
    fill_in "Wre", with: @competition.wre_id
    click_on "Create Competition"

    assert_text "Competition was successfully created"
    click_on "Back"
  end

  test "updating a Competition" do
    visit competitions_url
    click_on "Edit", match: :first

    fill_in "Checksum", with: @competition.checksum
    fill_in "Competition name", with: @competition.competition_name
    fill_in "Country", with: @competition.country
    fill_in "Date", with: @competition.date
    fill_in "Location", with: @competition.location
    fill_in "Type", with: @competition.type
    fill_in "Wre", with: @competition.wre_id
    click_on "Update Competition"

    assert_text "Competition was successfully updated"
    click_on "Back"
  end

  test "destroying a Competition" do
    visit competitions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Competition was successfully destroyed"
  end
end
