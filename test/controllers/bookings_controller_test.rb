require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @booking = bookings(:customer_paris)
    @rome = tours(:rome)
  end

  test "customer sees only their bookings" do
    sign_in users(:customer)
    get bookings_url
    assert_response :success
  end

  test "admin sees all bookings" do
    sign_in users(:admin)
    get bookings_url
    assert_response :success
  end

  test "agent sees bookings for their own tour only" do
    sign_in users(:agent)
    get bookings_url(tour_id: tours(:paris).id)
    assert_response :success

    get bookings_url(tour_id: @rome.id)
    assert_access_denied
  end

  test "customer books seats and availability drops" do
    sign_in users(:customer)
    get new_booking_url(tour_id: @rome.id)
    assert_response :success

    assert_difference("Booking.count") do
      post bookings_url, params: { tour_id: @rome.id, booking: { no_of_seats: 4, tour_id: @rome.id, user_id: users(:customer).id } }
    end
    assert_redirected_to booking_url(Booking.last)
    assert_equal 6, @rome.reload.avail_seats
  end

  test "cannot book on behalf of another user" do
    sign_in users(:customer)
    assert_no_difference("Booking.count") do
      post bookings_url, params: { booking: { no_of_seats: 1, tour_id: @rome.id, user_id: users(:other_customer).id } }
    end
    assert_access_denied
  end

  test "cannot book the same tour twice" do
    sign_in users(:customer)
    assert_no_difference("Booking.count") do
      post bookings_url, params: { tour_id: tours(:paris).id, booking: { no_of_seats: 1, tour_id: tours(:paris).id, user_id: users(:customer).id } }
    end
    assert_redirected_to root_path
  end

  test "overbooking waitlists the remaining seats" do
    sign_in users(:other_customer)
    assert_difference("Waitlist.count") do
      post bookings_url, params: { tour_id: @rome.id, booking: {
        no_of_seats: 13, tour_id: @rome.id, user_id: users(:other_customer).id,
        option: "Book all avaialble seats and waitlist remaining"
      } }
    end
    assert_equal 10, Booking.last.no_of_seats
    assert_equal 0, @rome.reload.avail_seats
  end

  test "agent cannot book" do
    sign_in users(:agent)
    get new_booking_url(tour_id: @rome.id)
    assert_access_denied
  end

  test "owner shows, edits and reduces a booking" do
    sign_in users(:customer)
    get booking_url(@booking)
    assert_response :success
    get edit_booking_url(@booking)
    assert_response :success

    patch booking_url(@booking), params: { booking: { no_of_seats: 1 } }
    assert_redirected_to booking_url(@booking)
    assert_equal 1, @booking.reload.no_of_seats
    assert_equal 19, tours(:paris).reload.avail_seats
  end

  test "booking cannot be increased" do
    sign_in users(:customer)
    patch booking_url(@booking), params: { booking: { no_of_seats: 5 } }
    assert_response :success
    assert_equal 2, @booking.reload.no_of_seats
  end

  test "other customer cannot view or cancel the booking" do
    sign_in users(:other_customer)
    get booking_url(@booking)
    assert_access_denied

    assert_no_difference("Booking.count") { delete booking_url(@booking) }
    assert_access_denied
  end

  test "owner cancels a booking and seats are returned" do
    sign_in users(:customer)
    Review.where(booking: @booking).delete_all
    assert_difference("Booking.count", -1) { delete booking_url(@booking) }
    assert_redirected_to bookings_url
    assert_equal 20, tours(:paris).reload.avail_seats
  end
end
