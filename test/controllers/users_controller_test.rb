require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "admin lists users, agents and customers" do
    sign_in users(:admin)
    get users_url
    assert_response :success
    get agents_url
    assert_response :success
    get customers_url
    assert_response :success
  end

  test "non-admins cannot list users" do
    sign_in users(:customer)
    get users_url
    assert_redirected_to root_path
  end

  test "admin creates a customer" do
    sign_in users(:admin)
    get user_new_url
    assert_response :success

    assert_difference("User.count") do
      post user_create_url, params: { user: {
        first_name: "New", email: "new@example.com", role: "Customer",
        password: "password123", password_confirmation: "password123"
      } }
    end
    assert_redirected_to root_path
    assert User.find_by(email: "new@example.com").is_customer
  end

  test "non-admins cannot create users" do
    sign_in users(:customer)
    assert_no_difference("User.count") do
      post user_create_url, params: { user: {
        first_name: "Sneaky", email: "sneaky@example.com", role: "Agent",
        password: "password123", password_confirmation: "password123"
      } }
    end
    assert_access_denied
  end

  test "user edits their own profile" do
    user = users(:customer)
    sign_in user
    get user_edit_url(user)
    assert_response :success

    patch "/user/#{user.id}", params: { user: { first_name: "Renamed", role: "Customer" } }
    assert_redirected_to root_path
    assert_equal "Renamed", user.reload.first_name
  end

  test "user cannot edit someone else" do
    sign_in users(:customer)
    patch "/user/#{users(:other_customer).id}", params: { user: { first_name: "Hijacked", role: "Customer" } }
    assert_access_denied
    assert_equal "Another", users(:other_customer).reload.first_name
  end

  test "admin deletes a user without dependent records" do
    sign_in users(:admin)
    assert_difference("User.count", -1) { delete admin_destroy_user_url(users(:other_customer)) }
    assert_redirected_to users_url
  end

  test "admin account cannot be deleted" do
    sign_in users(:admin)
    assert_no_difference("User.count") { delete admin_destroy_user_url(users(:admin)) }
    assert_redirected_to root_path
  end
end
