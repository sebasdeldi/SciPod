FactoryBot.define do
  factory :podcast do
    title { "MyString" }
    issn { "MyString" }
    doi { "MyString" }
    summary { "MyText" }
    script { "MyText" }
    user { nil }
  end
end
