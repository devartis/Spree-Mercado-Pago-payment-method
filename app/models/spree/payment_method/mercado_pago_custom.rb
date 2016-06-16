class Spree::PaymentMethod::MercadoPagoCustom < Spree::PaymentMethod
  APPROVED = 'approved'
  PENDING = 'in_process'
  REJECTED = 'rejected'

  preference :app_name, :string
  preference :public_key_production, :string
  preference :access_token_production, :string
  preference :public_key_sandbox, :string
  preference :access_token_sandbox, :string
  preference :sandbox, :boolean, default: true
  preference :statement_descriptor, :string, default: 'MERCADOPAGO'
  preference :send_additional_info, :boolean, default: false

  scope :active, -> { where(active: true) }

  def auto_capture?
    false
  end

  def public_key
    if preferred_sandbox
      preferred_public_key_sandbox
    else
      preferred_public_key_production
    end
  end

  def access_token
    if preferred_sandbox
      preferred_access_token_sandbox
    else
      preferred_access_token_production
    end
  end

  def payment_source_class
    ::Spree::MercadoPagoCustomSource
  end

  def provider_class
    ::Spree::MercadoPago::CustomClient::Provider
  end

  def provider
    provider_class.new self.access_token, self.public_key
  end

  def capture(amount, response_code, gateway_options)
    payment = get_payment(gateway_options)
    source = payment.source

    payment_info = get_payment_info(payment)
    result = is_success?(payment_info)
    source.update(raw_response: payment_info)
    if result
      source.update(state: payment_info[:status])
    else
      source.save_response_error(payment_info)
    end

    ActiveMerchant::Billing::Response.new(result, 'MercadoPago Payment Processed', {})
  end

  def try_capture(payment)
    payment_info = get_payment_info(payment)
    unless is_pending?(payment_info)
      begin
        payment.capture!
      rescue ::Spree::Core::GatewayError => e
        Rails.logger.error e.message
      end
    end
  end

  def authorize(amount, source, gateway_options)
    order = get_payment(gateway_options).order
    email = gateway_options[:email]
    user = Spree::User.find(gateway_options[:customer_id])

    #Get MercadoPago Customer ID
    if user.mercado_pago_customer_id
      mercado_pago_customer_id = user.mercado_pago_customer_id
    else
      mercado_pago_customer_id = provider.customers.find_or_create email
      if mercado_pago_customer_id
        user.update(mercado_pago_customer_id: mercado_pago_customer_id)
      else
        Rails.logger.error("MercadoPago: There was an error creating a MP customer for user #{user.id}")
      end
    end

    #Get payment options. If user uses a known card, we can just send the payer_id
    is_known_card = source.integration_payment_method_id.nil?
    if is_known_card
      payer_options = {payer_id: mercado_pago_customer_id}
    else
      payer_options = {payment_method_id: source.integration_payment_method_id, payer_email: email}
    end

    description = order.line_items.map { |line_item| line_item.variant.name }.join(', ')
    additional_info = additional_info(order)
    formatted_amount = amount.to_f / 100
    response = provider.payments.create(formatted_amount, source.card_token, description, source.installments, additional_info, payer_options)
    source.update(raw_response: response)
    if response[:status].present?
      source.update(state: response[:status])
    end

    success = is_success?(response) || is_pending?(response)

    deliver_payment_confirmation(response, gateway_options)

    if success
      source.update(mercado_pago_id: response[:id], external_reference: response[:external_reference])
      unless is_known_card
        associated = provider.customers.associate_card(mercado_pago_customer_id, source.card_token)
        unless associated
          Rails.logger.error("MercadoPago: There was an error associating card for user #{user.id} with Mercado Pago Customer ID #{mercado_pago_customer_id}")
        end
      end
    else
      Rails.logger.error("MercadoPago: Unable to create payment. Response #{response}")
      source.save_response_error(response)
    end

    ActiveMerchant::Billing::Response.new(success, 'MercadoPago Custom Checkout Payment Authorized', {})
  end

  private

  def deliver_payment_confirmation(response, gateway_options)
    payment = get_payment(gateway_options)
    order = payment.order
    if order.respond_to?(:deliver_payment_confirmation?)
      if is_pending?(response)
        order.update_attributes!(deliver_payment_confirmation: true)
      end
    end
  end

  def get_payment(gateway_options)
    identifier = identifier(gateway_options[:order_id])
    Spree::Payment.find_by! identifier: identifier
  end

  def get_payment_info(payment)
    response = provider.payments.search({id: payment.source.mercado_pago_id})
    if response[:results].empty?
      {status: PENDING}
    else
      response[:results].first
    end
  end

  def is_success?(response)
    response[:status] == APPROVED
  end

  def is_pending?(response)
    response[:status] == PENDING
  end

  def additional_info(order)
    default = {
        statement_descriptor: self.preferred_statement_descriptor,
        external_reference: order.number
    }
    return default unless self.preferred_send_additional_info

    begin
      items = order.line_items.map do |line_item|
        variant = line_item.variant
        image = unless variant.images.empty?
                  variant.images.first
                else
                  variant.product.images.first
                end
        {
            id: variant.id,
            title: variant.name,
            #If image is extracted from product.images, it could be nil
            picture_url: image ? image.attachment.url(:original) : '',
            description: variant.description,
            quantity: line_item.quantity,
            unit_price: line_item.price.to_s
        }
      end
      bill_address = order.bill_address
      ship_address = order.ship_address
      default.merge({
                        additional_info: {
                            items: items,
                            payer: {
                                first_name: bill_address.firstname,
                                last_name: bill_address.lastname,
                                registration_date: order.user.created_at.to_s,
                                phone: {
                                    number: bill_address.phone
                                },
                                address: {
                                    street_name: bill_address.address1,
                                    zip_code: bill_address.zipcode
                                }
                            },
                            shipments: {
                                receiver_address: {
                                    zip_code: ship_address.zipcode,
                                    street_name: ship_address.address1,
                                    floor: ship_address.address2
                                }
                            }
                        }
                    })
    rescue => e
      #If additional info processing fails for some reason, we shouldn't avoid doing the payment.
      Rails.logger.error "Exception raised while processing additional.info: #{e.message}"
      default
    end
  end

  def identifier(order_id)
    order_id.split('-').last
  end

end