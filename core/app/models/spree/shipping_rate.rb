module Spree
  class ShippingRate < Spree::Base
    belongs_to :shipment, class_name: 'Spree::Shipment'
    belongs_to :shipping_method, class_name: 'Spree::ShippingMethod', inverse_of: :shipping_rates
    belongs_to :tax_rate, class_name: 'Spree::TaxRate'

    delegate :order, :currency, to: :shipment
    delegate :name, to: :shipping_method

    def display_base_price
      Spree::Money.new(cost, currency: currency)
    end

    def display_tax_amount
      Spree::Money.new(tax_rate.calculator.compute_shipping_rate(self), currency: currency)
    end

    def display_price
      price = display_base_price.to_s
      if tax_rate
        amount = "#{display_tax_amount} #{tax_rate.name}"
        if tax_rate.included_in_price?
          price += " (incl. #{amount})"
        else
          price += " (+ #{amount})"
        end
      end
      price
    end
    alias_method :display_cost, :display_price

    def shipping_method
      Spree::ShippingMethod.unscoped { super }
    end

    def tax_rate
      Spree::TaxRate.unscoped { super }
    end
  end
end
