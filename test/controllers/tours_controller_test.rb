require "test_helper"

class ToursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tour = tours(:paris)
  end

  def tour_params(overrides = {})
    {
      Name: "Berlin Weekend", Description: "Two days in Berlin", Price: 900,
      start_date: 40.days.from_now.to_date, end_date: 42.days.from_now.to_date,
      booking_deadline: 20.days.from_now.to_date, pickup: "true", status: "Active",
      countries: "Germany", states: "Berlin", total_seats: 15
    }.merge(overrides)
  end

  test "requires sign in" do
    get tours_url
    assert_redirected_to new_user_session_url
  end

  test "lists and shows tours" do
    sign_in users(:customer)
    get tours_url
    assert_response :success
    assert_match @tour.Name, response.body

    get tour_url(@tour)
    assert_response :success
  end

  test "agent creates a tour" do
    sign_in users(:agent)
    get new_tour_url
    assert_response :success

    assert_difference("Tour.count") do
      post tours_url, params: { tour: tour_params }
    end
    tour = Tour.last
    assert_redirected_to tour_url(tour)
    assert_equal users(:agent).id, tour.user_id
    assert_equal 15, tour.avail_seats
  end

  test "invalid tour re-renders the form" do
    sign_in users(:agent)
    assert_no_difference("Tour.count") do
      post tours_url, params: { tour: tour_params(Name: "") }
    end
    assert_response :success
  end

  test "customer cannot create a tour" do
    sign_in users(:customer)
    get new_tour_url
    assert_access_denied

    assert_no_difference("Tour.count") do
      post tours_url, params: { tour: tour_params }
    end
    assert_access_denied
  end

  test "owner edits and updates their tour" do
    sign_in users(:agent)
    get edit_tour_url(@tour)
    assert_response :success

    patch tour_url(@tour), params: { tour: { Name: "Paris Deluxe" } }
    assert_redirected_to tour_url(@tour)
    assert_equal "Paris Deluxe", @tour.reload.Name
  end

  test "another agent cannot update or destroy the tour" do
    sign_in users(:other_agent)
    patch tour_url(@tour), params: { tour: { Name: "Hijacked" } }
    assert_access_denied
    assert_equal "Paris Highlights", @tour.reload.Name

    assert_no_difference("Tour.count") { delete tour_url(@tour) }
    assert_access_denied
  end

  test "admin destroys a tour" do
    sign_in users(:admin)
    tour = tours(:rome)
    Waitlist.where(tour: tour).delete_all
    assert_difference("Tour.count", -1) { delete tour_url(tour) }
    assert_redirected_to tours_url
  end

  test "search filters by name" do
    sign_in users(:customer)
    post tour_search_url, params: { search_params: { Name: "Rome" } }
    assert_response :success
    assert_match "Rome Classic", response.body
    assert_no_match "Paris Highlights", response.body
  end

  test "unknown tour redirects instead of erroring" do
    sign_in users(:customer)
    get tour_url(id: 0)
    assert_redirected_to root_path
  end
end
