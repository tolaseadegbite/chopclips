# 1. Speed up password hashing just for the seed process
require 'bcrypt'
BCrypt::Engine.cost = 1

puts "🌱 Seeding database..."

# Optional: Clean up existing data to avoid unique constraint errors
Membership.delete_all
Account.delete_all
User.delete_all

# 2. Create the Specific User
User.create!(
  first_name: "Tolase",
  last_name: "Adegbite",
  email: "tolasekelvin@chopclips.com",
  password: "foobarbazed!!",
  password_confirmation: "foobarbazed!!",
  verified: true,
  credits: 500
)
puts "✅ Created Tolase Adegbite"

# 3. Create 199 Faker Users
# Note: The 'after_create' callback in your User model will automatically
# create a Personal Workspace (Account) and Membership for each of these users.
199.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  User.create!(
    first_name: first_name,
    last_name: last_name,
    email: Faker::Internet.unique.email,
    password: "password123456",
    password_confirmation: "password123456",
    verified: [ true, true, false ].sample, # 66% chance of being verified
    credits: rand(0..200)
  )
end

puts "✅ Created 199 random users"
puts "🚀 Done! Total Users: #{User.count}"
