# The original lockable migration defaulted failed_attempts to 5, the same value as
# Devise's maximum_attempts, so a single wrong password locked a fresh account.
class FixUsersFailedAttemptsDefault < ActiveRecord::Migration[8.1]
  def up
    change_column_default :users, :failed_attempts, from: 5, to: 0
    execute "UPDATE users SET failed_attempts = 0 WHERE locked_at IS NULL"
  end

  def down
    change_column_default :users, :failed_attempts, from: 0, to: 5
  end
end
