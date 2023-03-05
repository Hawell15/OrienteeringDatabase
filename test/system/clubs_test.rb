require "application_system_test_case"

class ClubsTest < ApplicationSystemTestCase
  setup do
    @club = clubs(:one)
  end

  test "visiting the index" do
    visit clubs_url
    assert_selector "h1", text: "Clubs"
  end

  test "creating a Club" do
    visit clubs_url
    click_on "New Club"

    fill_in "Club name", with: @club.club_name
    fill_in "Email", with: @club.email
    fill_in "Phone", with: @club.phone
    fill_in "Representative", with: @club.representative
    fill_in "Territory", with: @club.territory
    click_on "Create Club"

    assert_text "Club was successfully created"
    click_on "Back"
  end

  test "updating a Club" do
    visit clubs_url
    click_on "Edit", match: :first

    fill_in "Club name", with: @club.club_name
    fill_in "Email", with: @club.email
    fill_in "Phone", with: @club.phone
    fill_in "Representative", with: @club.representative
    fill_in "Territory", with: @club.territory
    click_on "Update Club"

    assert_text "Club was successfully updated"
    click_on "Back"
  end

  test "destroying a Club" do
    visit clubs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Club was successfully destroyed"
  end
end
