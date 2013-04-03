FactoryGirl.define do
  factory :base_product, :class => Spree::Product do
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    description { Faker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
    price 19.99
    cost_price 17.00
    sku 'ABC'
    available_on 1.year.ago
    deleted_at nil
  end

  factory :simple_product, :parent => :base_product do
    on_hand 5
  end

  factory :product, :parent => :simple_product do
    tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }
    shipping_category { |r| Spree::ShippingCategory.first || r.association(:shipping_category) }
  end

  factory :product_with_option_types, :parent => :product do
    after_create { |product| FactoryGirl.create(:product_option_type, :product => product) }
  end

  factory :custom_product, :class => Spree::Product do
    name "Custom Product"
    price "17.99"
    description { Faker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
    on_hand 5

    # associations:
    tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }
    shipping_category { |r| Spree::ShippingCategory.first || r.association(:shipping_category) }

    sku 'ABC'
    available_on 1.year.ago
    deleted_at nil

    association :taxons
  end
end
