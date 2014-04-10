# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

GOLD = %w[famous_question fanatic great_answer great_question stellar_question]
SILVER = %w[civic_duty enthusiast favorite_question good_question
            good_answer notable_question taxonomist yearling]
BRONZE = %w[autobiographer citizen_patrol cleanup commentator critic disciplined editor
            nice_answer nice_question peer_pressure popular_question scholar
            self_learner supporter teacher]

GOLD.each do |name| Badge.create(:name=>name,:badge_type=>Badge::GOLD) end
SILVER.each do |name| Badge.create(:name=>name,:badge_type=>Badge::SILVER) end
BRONZE.each do |name| Badge.create(:name=>name,:badge_type=>Badge::BRONZE) end
puts 'badges feeded'