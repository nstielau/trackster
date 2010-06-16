require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get twitter dashboard" do
    get :twitter_dashboard
    assert_response :success
    assert_select("h2", "Twitter Dashboard")
  end
end
