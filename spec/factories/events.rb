require 'faker'

FactoryGirl.define do
  factory :event do
    title "Event title"
    description "Event description"
    lobby_activity true
    published_at Date.yesterday
    scheduled Time.now
    location "Ayuntamiento de Madrid"
    association :position, factory: :position
    association :user, factory: :user
  end
end
