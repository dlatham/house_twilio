# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(fname: 'Dave', lname: 'Latham', phone: '+13107950475', email: 'dave.latham@gmail.com', password: 'chinstrap', password_confirmation: 'chinstrap', guest: false, active: true, admin: true)
Greeting.create(text: 'Yo %s!', stranger: true, time_of_day: 'all')