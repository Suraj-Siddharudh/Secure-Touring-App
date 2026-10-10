require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "signs in with email and password" do
    get new_user_session_url
    assert_response :success
    assert_select "link[href*=?]", "/assets/application"
    assert_select "script[src*=?]", "/assets/application"

    post user_session_url, params: { user: { email: "customer@example.com", password: "password123" } }
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
  end

  test "signs up as a customer" do
    get new_user_registration_url
    assert_response :success

    assert_difference("User.count") do
      post user_registration_url, params: { user: {
        first_name: "Sam", email: "sam@example.com", role: "Customer",
        password: "password123", password_confirmation: "password123"
      } }
    end
    user = User.find_by(email: "sam@example.com")
    assert user.is_customer
    assert_not user.is_agent
    assert_not user.is_admin
  end

  test "one wrong password does not lock the account" do
    post user_session_url, params: { user: { email: "customer@example.com", password: "wrong" } }
    assert_not users(:customer).reload.access_locked?

    post user_session_url, params: { user: { email: "customer@example.com", password: "password123" } }
    assert_redirected_to root_url
  end

  test "google sign in cannot be started with a GET request" do
    get "/users/auth/google"
    assert_not_includes response.location.to_s, "accounts.google.com"
  end

  test "unknown paths render the not found page" do
    sign_in users(:customer)
    get "/no/such/page"
    assert_response :not_found
  end
end
