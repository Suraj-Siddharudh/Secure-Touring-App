require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bookmark = bookmarks(:customer_paris)
  end

  test "customer lists and shows their bookmarks" do
    sign_in users(:customer)
    get bookmarks_url
    assert_response :success
    get bookmark_url(@bookmark)
    assert_response :success
  end

  test "customer bookmarks a tour" do
    sign_in users(:customer)
    assert_difference("Bookmark.count") do
      post bookmarks_url, params: { tour_id: tours(:rome).id }
    end
    assert_redirected_to bookmark_url(Bookmark.last)
    assert_equal users(:customer).id, Bookmark.last.user_id
  end

  test "agent cannot bookmark" do
    sign_in users(:agent)
    assert_no_difference("Bookmark.count") do
      post bookmarks_url, params: { tour_id: tours(:rome).id }
    end
    assert_access_denied
  end

  test "other customer cannot view or delete the bookmark" do
    sign_in users(:other_customer)
    get bookmark_url(@bookmark)
    assert_access_denied
    assert_no_difference("Bookmark.count") { delete bookmark_url(@bookmark) }
    assert_access_denied
  end

  test "owner deletes the bookmark" do
    sign_in users(:customer)
    assert_difference("Bookmark.count", -1) { delete bookmark_url(@bookmark) }
    assert_redirected_to bookmarks_url
  end
end
