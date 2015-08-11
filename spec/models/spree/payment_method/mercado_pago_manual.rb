require_relative '../../spec_helper.rb'

shared_examples 'should not be captured' do
  it 'should not be captured' do
    payment.should_not_receive(:capture!)
    subject.try_capture(payment)
  end
end

shared_examples 'should be captured' do
  it 'should be captured' do
    payment.should_receive(:capture!)
    subject.try_capture(payment)
  end
end

describe PaymentMethod::MercadoPagoManual do
  let (:payment) { create :mp_manual_payment }
  subject { payment.payment_method }

  before(:each) do
    mock_authenticate subject.preferred_client_id, subject.preferred_client_secret
    mock_get_money_request payment.source.mercado_pago_id, money_request_status
    mp_payment_status = (defined? mercado_pago_payment_status) ? mercado_pago_payment_status : nil
    mock_get_payment_status payment.source.external_reference, mp_payment_status
  end

  context 'with a pending money request' do
    let(:money_request_status) { 'pending' }
    include_examples 'should not be captured'
  end

  context 'with an accepted money request' do
    let(:money_request_status) { 'accepted' }

    context 'with a pending mercado pago payment' do
      let(:mercado_pago_payment_status) { 'pending' }
      include_examples 'should not be captured'
    end

    context 'with an approved mercado pago payment' do
      let(:mercado_pago_payment_status) { 'approved' }
      include_examples 'should be captured'
    end
  end

  context 'with a cancelled money request' do
    let(:money_request_status) { 'cancelled' }
    include_examples 'should be captured'
  end

  context 'with a rejected money request' do
    let(:money_request_status) { 'rejected' }
    include_examples 'should be captured'
  end
end