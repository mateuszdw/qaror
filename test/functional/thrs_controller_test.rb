require 'test_helper'

class ThrsControllerTest < ActionController::TestCase
  setup do
    @thr = thrs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:thrs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create thr" do
    assert_difference('Thr.count') do
      post :create, thr: { activity_at: @thr.activity_at, content: @thr.content, hits: @thr.hits, last_activity_id: @thr.last_activity_id, last_activity_user_id: @thr.last_activity_user_id, status: @thr.status, title: @thr.title, vote_down: @thr.vote_down, vote_up: @thr.vote_up }
    end

    assert_redirected_to thr_path(assigns(:thr))
  end

  test "should show thr" do
    get :show, id: @thr
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @thr
    assert_response :success
  end

  test "should update thr" do
    put :update, id: @thr, thr: { activity_at: @thr.activity_at, content: @thr.content, hits: @thr.hits, last_activity_id: @thr.last_activity_id, last_activity_user_id: @thr.last_activity_user_id, status: @thr.status, title: @thr.title, vote_down: @thr.vote_down, vote_up: @thr.vote_up }
    assert_redirected_to thr_path(assigns(:thr))
  end

  test "should destroy thr" do
    assert_difference('Thr.count', -1) do
      delete :destroy, id: @thr
    end

    assert_redirected_to thrs_path
  end
end
