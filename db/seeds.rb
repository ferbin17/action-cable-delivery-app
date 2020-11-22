# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if User.where(is_merchant: false).count == 0
  User.create(email_id: "user1@test.com", password: "password", confirm_password: "password")
  User.create(email_id: "user2@test.com", password: "password", confirm_password: "password")
end

if User.where(is_merchant: false).count == 0
  User.create(email_id: "merchant_id1@test.com", password: "password", confirm_password: "password", is_merchant: true)
  User.create(email_id: "merchant_id2@test.com", password: "password", confirm_password: "password", is_merchant: true)
end

if Product.all.count == 0
  10.times do |i|
    Product.create(name: "Product #{i+1}", price: 10.times.map{ (1..40).to_a.sample + Random.rand(11)}.sample, merchant_id: User.where(is_merchant: true).collect(&:id).sample)
  end
end