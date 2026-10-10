require 'faker'

# Passwords for the built-in accounts come from the environment. If a variable
# is not set, a random password is generated and printed once.
def seed_password(env_name, label)
  ENV.fetch(env_name) do
    SecureRandom.alphanumeric(16).tap { |pw| puts "#{label} password (set #{env_name} to choose your own): #{pw}" }
  end
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# Examples:

#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!([{
  first_name: 'Admin', 
  last_name: 'Admin', 
  email: 'admin@touringapp.com',
  password: seed_password('ADMIN_PASSWORD', 'Admin'), 
  is_customer: 0, 
  is_agent: 0, 
  is_admin: 1,
  phone_number: '1800-12-1234',
}])
User.create!([{
  first_name: 'Customer', 
  last_name: 'K', 
  email: 'customer@touringapp.com',
  password: seed_password('CUSTOMER_PASSWORD', 'Customer'), 
  is_customer: 1, 
  is_agent: 0, 
  is_admin: 0,
  phone_number: '1800-12-1236',
}])

User.create!([{
  first_name: 'Agent', 
  last_name: 'J', 
  email: 'agent@touringapp.com',
  password: seed_password('AGENT_PASSWORD', 'Agent'), 
  is_customer: 0, 
  is_agent: 1, 
  is_admin: 0,
  phone_number: '1800-12-1235',
}])

# Create 15 Agents
15.times do
  User.create(
    first_name: Faker::Name.unique.first_name, 
    last_name: Faker::Name.last_name, 
    email: Faker::Internet.email,
    password: Faker::Internet.password(min_length: 8, max_length: 16, mix_case: true, special_characters: true), 
    is_customer: 0, 
    is_agent: 1, 
    is_admin: 0,
    phone_number: Faker::PhoneNumber.phone_number
  )
end
# Create 10 Customers
10.times do
  User.create(
    first_name: Faker::Name.unique.first_name, 
    last_name: Faker::Name.last_name, 
    email: Faker::Internet.email,
    password: Faker::Internet.password(min_length: 8, max_length: 16, mix_case: true, special_characters: true), 
    is_customer: 1, 
    is_agent: 0, 
    is_admin: 0,
    phone_number: Faker::PhoneNumber.phone_number
  )
end

5.times do
  Tour.create(
    Name: Faker::Company.name, 
    Description: Faker::Marketing.buzzwords, 
    Price: Faker::Number.between(from: 100, to: 30000),
    start_date: start_date = Faker::Date.between(from: 20.days.from_now, to: 40.days.from_now),
    end_date: start_date + rand(2..10).days,
    pickup: Faker::Boolean.boolean, 
    total_seats: Faker::Number.between(from: 10, to: 90),
    status: "Active",
    booking_deadline: start_date - rand(1..10).days,
    countries: Faker::Address.country,
    states: Faker::Address.state,
    user_id: 3
  )
end

10.times do
  Tour.create(
    Name: Faker::Company.name, 
    Description: Faker::Marketing.buzzwords, 
    Price: Faker::Number.between(from: 100, to: 30000),
    start_date: start_date = Faker::Date.between(from: 20.days.from_now, to: 40.days.from_now),
    end_date: start_date + rand(2..10).days,
    pickup: Faker::Boolean.boolean, 
    total_seats: Faker::Number.between(from: 10, to: 90),
    status: "Active",
    booking_deadline: start_date - rand(1..10).days,
    countries: Faker::Address.country,
    states: Faker::Address.state,
    user_id: Faker::Number.between(from: 3, to: 18)
  )
end