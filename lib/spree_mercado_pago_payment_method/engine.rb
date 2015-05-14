# -*- encoding : utf-8 -*-
require 'spree_core'

module SpreeMercadoPagoPaymentMethod
  class Engine < Rails::Engine

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), "../../app/overrides/*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

    initializer "spree_payment_network.register.payment_methods" do |app|
      app.config.spree.payment_methods += [Spree::PaymentMethod::MercadoPagoBasic]
      app.config.spree.payment_methods += [Spree::PaymentMethod::MercadoPagoManual]
      app.config.spree.payment_methods += [Spree::PaymentMethod::MercadoPagoCustom]
    end

    Spree::PermittedAttributes.source_attributes << :payer_email
    Spree::PermittedAttributes.source_attributes << :description

    config.to_prepare &method(:activate).to_proc
  end
end
