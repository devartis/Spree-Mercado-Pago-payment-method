require 'spec_helper'

describe PaymentMethod::MercadoPagoManual do
  let (:payment) { create :mp_manual_payment }
  subject { payment.payment_method }

  before :each do
    mock_authenticate(subject.preferred_client_id, subject.preferred_client_secret)
    mock_get_money_request(payment.source.mercado_pago_id, 'pending')
  end

  context 'a pending money request' do
    it do
      payment.should_not_receive(:capture!)
      subject.try_capture(payment)
    end
  end

end