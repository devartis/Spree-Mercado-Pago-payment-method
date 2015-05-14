class Spree::PaymentMethod::MercadoPago < Spree::PaymentMethod

  preference :client_id, :string
  preference :client_secret, :string
  preference :mode, :string, default: 'modal'
  preference :success_url, :string, default: ''
  preference :failure_url, :string, default: ''
  preference :pending_url, :string, default: ''
  preference :sandbox, :boolean, default: true
  preference :confirmation_url, :string, default: ''

  include ::Spree::MercadoPago::Provider

  def default_options
    {sandbox: preferred_sandbox}
  end

  def payment_profiles_supported?
    false
  end

  def auto_capture?
    false
  end

  def payment_source_class
    nil
  end

  def authorize(amount, source, gateway_options)
    status = provider.get_payment_status identifier(gateway_options[:order_id])
    success = !Spree::MercadoPago::PaymentStatus.failed?(status)
    ActiveMerchant::Billing::Response.new(success, 'MercadoPago payment authorized', {status: status})
  end

  def capture(amount, source, gateway_options)
    status = provider.get_payment_status identifier(gateway_options[:order_id])
    success = Spree::MercadoPago::PaymentStatus.approved?(status)
    ActiveMerchant::Billing::Response.new(success, 'MercadoPago payment processed', {status: status})
  end

  def try_capture payment
    status = provider.get_payment_status payment.identifier

    if can_capture?(payment) and not Spree::MercadoPago::PaymentStatus.pending?(status)
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
    Spree::MercadoPago::PaymentStatus.approved?(status)
  end

  def can_void?(payment)
    !payment.void?
  end

  def can_capture?(payment)
    payment.pending? || payment.checkout?
  end

  def cancel(response_code)
    Rails.logger.info response_code
  end

  private

  def identifier(order_id)
    order_id.split('-')[1]
  end

end