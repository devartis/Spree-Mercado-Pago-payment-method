require 'spec_helper'

shared_examples 'should not be captured' do
  it 'should not be captured' do
    payment.should_not_receive(:capture!)
    subject.try_capture(payment)
  end
end

describe PaymentMethod::MercadoPagoManual do
  let (:payment) { create :mp_manual_payment }
  subject { payment.payment_method }

  before(:each) { mock_authenticate subject.preferred_client_id, subject.preferred_client_secret }

  context 'with a pending money request' do
    before(:each) { mock_get_money_request payment.source.mercado_pago_id, 'pending' }
    include_examples 'should not be captured'
  end

  context 'with an accepted money request' do
    before(:each) { mock_get_money_request payment.source.mercado_pago_id, 'accepted' }

    context 'with a pending mercado pago payment' do
      before(:each) { mock_get_payment_status 'pending', payment.source.external_reference }
      include_examples 'should not be captured'
    end

    context 'with an approved mercado pago payment' do
      before(:each) { mock_get_payment_status 'approved', payment.source.external_reference }
      it 'should be captured' do
        payment.should_receive(:capture!)
        subject.try_capture(payment)
      end
    end
  end
end