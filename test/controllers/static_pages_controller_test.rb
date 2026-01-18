require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get homepage" do
    get static_pages_homepage_url
    assert_response :success
  end

  test "should get pricing" do
    get static_pages_pricing_url
    assert_response :success
  end

  test "should get privacy" do
    get static_pages_privacy_url
    assert_response :success
  end

  test "should get support" do
    get static_pages_support_url
    assert_response :success
  end

  test "should get tos" do
    get static_pages_tos_url
    assert_response :success
  end

  test "should get privacy_policy" do
    get static_pages_privacy_policy_url
    assert_response :success
  end
end
