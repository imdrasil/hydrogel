FactoryGirl.define do
  factory :article do
    sequence(:title) { |n| "Article #{n}" }
  end
end