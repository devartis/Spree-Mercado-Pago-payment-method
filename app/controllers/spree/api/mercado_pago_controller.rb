module Spree
  module Api
    class MercadoPagoController < BaseController

      include Concerns::IpnNotification
      before_filter :find_order, :verify_payment_state, only: :payment

      # If the order is in 'payment' state, redirects to Mercado Pago Checkout page
      def payment
        mp_payment = @order.current_payment

        if mp_payment.source.nil? or mp_payment.source.redirect_url.nil?
          response = create_preferences mp_payment
          if response
            point_key = provider.sandbox ? 'sandbox_init_point' : 'init_point'
            redirect_url = response[point_key]

            mp_payment.source = MercadoPagoSource.create!
            mp_payment.source.redirect_url = redirect_url
            mp_payment.save!
          else
            render json: {ok: false}
            return
          end
        end

        render json: {redirect_url: mp_payment.source.redirect_url, ok: true}
      end

      private

      def find_order
        @order = Spree::Order.find_by!(number: params[:id])
      end

      def create_preferences(mp_payment)
        preferences = create_preference_options(@order, mp_payment, get_back_urls(mp_payment))

        Rails.logger.info 'Sending preferences to MercadoPago'
        Rails.logger.info "#{preferences}"

        provider.create_preferences(preferences)
      end

      def create_preference_options(order, payment, callbacks)
        builder = MercadoPago::OrderPreferencesBuilder.new order, payment, callbacks, payer_data

        return builder.preferences_hash
      end

      def payment_method
        @payment_method ||= if params[:payment_method_id]
                              ::PaymentMethod::MercadoPago.find (params[:payment_method_id])
                            else
                              # FIXME: This is not the best way. What happens with multiples MercadoPago payments?
                              ::PaymentMethod::MercadoPago.first
                            end
      end

      def provider
        @provider ||= payment_method.provider(payer_data)
      end

      # Get payer info for sending within Mercado Pago request
      def payer_data
        @order ? {payer: {email: @order.email}} : {}
      end

      # Get urls callbacks.
      # If the current 'payment method' haven't any callback, the default will be used
      def get_back_urls(mp_payment)
        success_url = payment_method.preferred_success_url
        pending_url = payment_method.preferred_pending_url
        failure_url = payment_method.preferred_failure_url

        get_params = {
            order_number: @order.number,
            payment_identifier: mp_payment.identifier
        }

        success_url = spree.mercado_pago_success_url(get_params) if success_url.empty?
        pending_url = spree.mercado_pago_pending_url(get_params) if pending_url.empty?
        failure_url = spree.mercado_pago_failure_url(get_params) if failure_url.empty?

        {
            success: success_url,
            pending: pending_url,
            failure: failure_url,
        }
      end

      def verify_payment_state
        redirect_to root_path unless @order.payment_confirmation?
      end

    end
  end

end
