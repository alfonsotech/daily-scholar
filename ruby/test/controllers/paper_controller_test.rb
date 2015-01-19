require 'test_helper'

class PaperControllerTest < ActionController::TestCase
  test "should get read" do
    get :read
    assert_response :success
  end

  test "should get save" do
    get :save
    assert_response :success
  end

  test "should get star" do
    get :star
    assert_response :success
  end

  test "should get download" do
    get :download
    assert_response :success
  end

end
