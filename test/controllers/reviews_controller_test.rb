require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @review = reviews(:customer_paris)
  end

  test "requires sign in for every action" do
    get edit_review_url(@review)
    assert_redirected_to new_user_session_url

    patch review_url(@review), params: { review: { subject: "Changed" } }
    assert_redirected_to new_user_session_url
    assert_equal "Great trip", @review.reload.subject
  end

  test "customer lists, shows and creates reviews" do
    sign_in users(:customer)
    get reviews_url
    assert_response :success
    get review_url(@review)
    assert_response :success
    get new_review_url(booking_id: bookings(:customer_paris).id)
    assert_response :success

    assert_difference("Review.count") do
      post reviews_url, params: { review: {
        subject: "Again", content: "Still great", tour_id: tours(:paris).id,
        booking_id: bookings(:customer_paris).id, user_id: users(:other_customer).id
      } }
    end
    assert_redirected_to review_url(Review.last)
    assert_equal users(:customer).id, Review.last.user_id, "user_id comes from the session, not params"
  end

  test "author updates the review" do
    sign_in users(:customer)
    get edit_review_url(@review)
    assert_response :success
    patch review_url(@review), params: { review: { subject: "Even better" } }
    assert_redirected_to review_url(@review)
    assert_equal "Even better", @review.reload.subject
  end

  test "other users cannot edit the review" do
    sign_in users(:other_customer)
    get edit_review_url(@review)
    assert_access_denied
    patch review_url(@review), params: { review: { subject: "Hijacked" } }
    assert_access_denied
    assert_equal "Great trip", @review.reload.subject
  end

  test "agent cannot write reviews" do
    sign_in users(:agent)
    get new_review_url
    assert_access_denied
  end

  test "admin deletes a review" do
    sign_in users(:admin)
    assert_difference("Review.count", -1) { delete review_url(@review) }
    assert_redirected_to reviews_url
  end
end
