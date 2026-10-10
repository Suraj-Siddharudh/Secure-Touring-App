require "test_helper"

class WaitlistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @waitlist = waitlists(:customer_rome)
  end

  test "requires sign in for every action" do
    assert_no_difference("Waitlist.count") { delete waitlist_url(@waitlist) }
    assert_redirected_to new_user_session_url

    patch waitlist_url(@waitlist), params: { waitlist: { no_of_seats: 99 } }
    assert_redirected_to new_user_session_url
  end

  test "customer lists and shows their waitlist entries" do
    sign_in users(:customer)
    get waitlists_url
    assert_response :success
    get waitlist_url(@waitlist)
    assert_response :success
  end

  test "agent sees waitlists for their own tour only" do
    sign_in users(:other_agent)
    get waitlists_url(tour_id: tours(:rome).id)
    assert_response :success

    get waitlists_url(tour_id: tours(:paris).id)
    assert_access_denied
  end

  test "non-admins cannot create or edit waitlist entries directly" do
    sign_in users(:customer)
    get new_waitlist_url
    assert_access_denied
    patch waitlist_url(@waitlist), params: { waitlist: { no_of_seats: 99 } }
    assert_access_denied
    assert_equal 3, @waitlist.reload.no_of_seats
  end

  test "admin updates a waitlist entry" do
    sign_in users(:admin)
    get edit_waitlist_url(@waitlist)
    assert_response :success
    patch waitlist_url(@waitlist), params: { waitlist: { no_of_seats: 2 } }
    assert_redirected_to waitlist_url(@waitlist)
    assert_equal 2, @waitlist.reload.no_of_seats
  end

  test "other customer cannot delete the entry" do
    sign_in users(:other_customer)
    assert_no_difference("Waitlist.count") { delete waitlist_url(@waitlist) }
    assert_access_denied
  end

  test "owner leaves the waitlist" do
    sign_in users(:customer)
    assert_difference("Waitlist.count", -1) { delete waitlist_url(@waitlist) }
    assert_redirected_to waitlists_url
  end
end
