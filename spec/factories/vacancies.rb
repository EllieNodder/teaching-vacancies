FactoryGirl.define do
  factory :vacancy do
    association :pay_scale
    association :subject
    association :leadership
    association :school

    job_title { Faker::Lorem.sentence }
    headline { Faker::Lorem.sentence }
    working_pattern { :full_time }
    job_description { Faker::Lorem.paragraph(4) }
    education { Faker::Lorem.paragraph(4) }
    qualifications { Faker::Lorem.paragraph(4) }
    experience { Faker::Lorem.paragraph(4) }
    status { :published }
    expires_on { Faker::Time.forward(14) }
    publish_on { Time.zone.today }
    minimum_salary { Faker::Number.number(5) }
    maximum_salary { Faker::Number.number(6) }
    contact_email { Faker::Internet.email }
    application_link { Faker::Internet.url }
    weekly_hours '8.5'
    benefits { Faker::Lorem.sentence }

    trait :fail_minimum_validation do
      job_title { Faker::Job.title[0..7] }
      headline { Faker::Lorem.sentence[0..6] }
      job_description { Faker::Lorem.paragraph[0..5] }
      experience { Faker::Lorem.paragraph[0..7] }
      education { Faker::Lorem.paragraph[0..8] }
      qualifications { Faker::Lorem.paragraph[0...8] }
    end

    trait :complete do
      starts_on { Faker::Time.forward(30) }
      ends_on { Faker::Time.forward(60) }
    end

    trait :draft do
      status { :draft }
    end

    trait :trashed do
      status { :trashed }
    end

    trait :published do
      status { :published }
    end

    trait :expired do
      publish_on { Faker::Time.backward(14) }
      expires_on { Faker::Time.backward(7) }
    end

    trait :job_schema do
      weekly_hours '8.5'
      education { Faker::Lorem.paragraph }
      benefits { Faker::Lorem.sentence }
    end
  end
end
