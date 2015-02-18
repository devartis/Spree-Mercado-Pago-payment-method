require 'spec_helper'

describe PaymentMethod::MercadoPagoManual do
  let (:payment) { create :mp_manual_payment }
  subject { payment.payment_method }

  before(:each) { mock_authenticate subject.preferred_client_id, subject.preferred_client_secret }

  context 'a pending money request' do
    before(:each) { mock_get_money_request payment.source.mercado_pago_id, 'pending' }

    it 'should not be captured' do
      payment.should_not_receive(:capture!)
      subject.try_capture(payment)
    end
  end

  context 'an accepted money request' do
    before(:each) { mock_get_money_request payment.source.mercado_pago_id, 'accepted' }

    context 'with a pending mercado pago payment' do
      before(:each) { mock_get_payment_status }

      it 'should not be captured' do
        payment.should_not_receive(:capture!)
        subject.try_capture(payment)
      end
    end
  end
end