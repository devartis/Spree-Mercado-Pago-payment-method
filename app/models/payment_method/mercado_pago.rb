# -*- encoding : utf-8 -*-
class PaymentMethod::MercadoPago < Spree::PaymentMethod

  preference :client_id, :string
  preference :client_secret, :string
  preference :mode, :string, default: 'modal'
  preference :success_url, :string, default: ''
  preference :failure_url, :string, default: ''
  preference :pending_url, :string, default: ''
  preference :sandbox, :boolean, default: true
  preference :confirmation_url, :string, default: ''

  def payment_profiles_supported?
    false
  end

  def provider_class
    ::MercadoPago::Client
  end

  def provider(additional_options={})
    options = {
      sandbox: preferred_sandbox
    }
    client = provider_class.new(self, options.merge(additional_options))
    client.authenticate
    client
  end

  def auto_capture?
    false
  end

  def payment_source_class
    nil
  end

  def authorize(amount, source, gateway_options)
    status = provider.get_payment_status identifier(gateway_options[:order_id])
    success = !failed?(status)
    ActiveMerchant::Billing::Response.new(success, 'MercadoPago payment authorized', {status: status})
  end

  def capture(amount, source, gateway_options)
    status = provider.get_payment_status identifier(gateway_options[:order_id])
    success = approved?(status)
    ActiveMerchant::Billing::Response.new(success, 'MercadoPago payment processed', {status: status})
  end

  def try_capture payment
    status = provider.get_payment_status payment.identifier

    if can_capture?(payment) and not pending?(status)
      # When the capture is not success, the payment raises a Core::GatewayError exception
      # See spree_core/app/models/spree/payment/processing.rb:156
      begin
        payment.capture!
      rescue ::Spree::Core::GatewayError => e
        Rails.logger.error e.message
      end
    end
  end

  def payment_approved?(payment)
    status = provider.get_payment_status payment.identifier
    approved?(status)
  end

  def can_void?(payment)
    !payment.void?
  end

  def can_capture?(payment)
    payment.pending? || payment.checkout?
  end

  private

  def identifier(order_id)
    order_id.split('-')[1]
  end

  def pending?(status)
    status == 'pending' or status == 'in_process' or status == 'in_mediation'
  end

  def failed?(status)
    status == 'rejected' or status == 'cancelled'
  end

  def approved?(status)
    status == 'approved'
  end

end
