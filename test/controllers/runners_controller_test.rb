require "test_helper"

class RunnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @runner = runners(:one)
  end

  test "should get index" do
    get runners_url
    assert_response :success
  end

  test "should get new" do
    get new_runner_url
    assert_response :success
  end

  test "should create runner" do
    assert_difference('Runner.count') do
      post runners_url, params: { runner: { best_category: @runner.best_category, category: @runner.category, category_valid: @runner.category_valid, checksum: @runner.checksum, club: @runner.club, dob: @runner.dob, forrest_wre_rang: @runner.forrest_wre_rang, gender: @runner.gender, runner_name: @runner.runner_name, sprint_wre_rang: @runner.sprint_wre_rang, surname: @runner.surname, wre_id: @runner.wre_id } }
    end

    assert_redirected_to runner_url(Runner.last)
  end

  test "should show runner" do
    get runner_url(@runner)
    assert_response :success
  end

  test "should get edit" do
    get edit_runner_url(@runner)
    assert_response :success
  end

  test "should update runner" do
    patch runner_url(@runner), params: { runner: { best_category: @runner.best_category, category: @runner.category, category_valid: @runner.category_valid, checksum: @runner.checksum, club: @runner.club, dob: @runner.dob, forrest_wre_rang: @runner.forrest_wre_rang, gender: @runner.gender, runner_name: @runner.runner_name, sprint_wre_rang: @runner.sprint_wre_rang, surname: @runner.surname, wre_id: @runner.wre_id } }
    assert_redirected_to runner_url(@runner)
  end

  test "should destroy runner" do
    assert_difference('Runner.count', -1) do
      delete runner_url(@runner)
    end

    assert_redirected_to runners_url
  end
end
