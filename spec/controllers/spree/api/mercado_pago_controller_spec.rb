require 'rspec'
require 'spec_helper'

describe Spree::Api::MercadoPagoController do
  let(:spree_api_key) do
    user = Spree.user_class.find_or_create_by email: 'foo@example.com'
    admin_role = Spree::Role.find_or_create_by!(name: 'admin')
    admin_role.users << user
    user.generate_spree_api_key!
    user.spree_api_key
  end
  let!(:payment_method) { create(:mercado_pago_payment_method) }
  let(:order) { Spree::Order.create(state: 'payment') }
  let(:payment) { create(:payment, payment_method: payment_method, order: order) }

  #Mock MP access oauth requests
  let(:access_token) { '123456' }
  before :each do
    subject.stub(:try_spree_current_user) { nil }
    stub_request(:post, /.*api.mercadolibre.com\/oauth\/token/).to_return(:status => 200, :body => {access_token: access_token}.to_json, :headers => {})
  end

  describe 'POST #notification' do
    shared_examples 'good responses' do
      it 'should respond 200 OK' do
        spree_post :notification, notification_params
        expect(response).to be_ok
      end

      it 'should respond a json with order_number key' do
        spree_post :notification, notification_params
        #Well `render nothing: true` returns " " instead of ""
        expect(JSON.parse(response.body).count).to eq(1)
      end
      it 'should respond ok if token is not provided' do
        spree_post :notification, notification_params.except(:token)
        #Well `render nothing: true` returns " " instead of ""
        expect(response).to be_ok
      end
      it 'should respond empty if token is not provided' do
        spree_post :notification, notification_params.except(:token)
        #Well `render nothing: true` returns " " instead of ""
        expect(response.body.strip).to be_blank
      end
    end

    context 'valid external reference' do
      it_behaves_like 'good responses'
      let(:operation_id) { 'valid_external_reference_id' }
      let(:external_reference) { payment.identifier }
      let(:notification_response) { {collection: {external_reference: external_reference}} }
      let(:notification_params) { {id: operation_id, token: spree_api_key} }
      before :each do
        subject.stub(:enqueue_verification) { true }
        stub_request(:get, /.*api.mercadolibre.com.*\/notifications\/#{operation_id}.*/).to_return(:status => 200, :body => notification_response.to_json, :headers => {})
      end

      it 'should call #enqueue_verification' do
        expect(subject).to receive(:enqueue_verification).with(anything()).and_return(true)
        spree_post :notification, notification_params
      end

      it 'should call #payment_by' do
        expect(subject).to receive(:payment_by).with(payment.identifier)
        spree_post :notification, notification_params
      end
    end

    context 'invalid external reference' do
      it_behaves_like 'good responses'
      let(:operation_id) { 'invalid_external_reference_id' }
      let(:notification_params) { {id: operation_id, token: spree_api_key} }
      before :each do
        stub_request(:get, /.*api.mercadolibre.com.*\/notifications\/#{operation_id}.*/).to_return(:status => 404, :body => '', :headers => {})
      end

      it 'should call #enqueue_verification' do
        expect(subject).to_not receive(:enqueue_verification)
        spree_post :notification, notification_params
      end

      it 'should call #payment_by' do
        expect(subject).to_not receive(:payment_by).with(payment.identifier)
        spree_post :notification, notification_params
      end

      it 'calls #log_no_external_reference' do
        expect(subject).to receive(:log_no_external_reference).with(operation_id)
        spree_post :notification, notification_params
      end
    end

    context 'invalid external reference' do
      it_behaves_like 'good responses'
      let(:operation_id) { 'valid_external_reference_id' }
      let(:notification_params) { {id: operation_id, token: spree_api_key} }
      let(:invalid_external_reference) { '123456789' }
      let(:notification_response) { {collection: {external_reference: invalid_external_reference}} }
      before :each do
        stub_request(:get, /.*api.mercadolibre.com.*\/notifications\/#{operation_id}.*/).to_return(:status => 202, :body => notification_response.to_json, :headers => {})
      end

      it 'should not call #enqueue_verification' do
        expect(subject).to_not receive(:enqueue_verification)
        spree_post :notification, notification_params
      end

      it 'should not call #payment_by' do
        expect(subject).to_not receive(:payment_by).with(payment.identifier)
        spree_post :notification, notification_params
      end

      it 'calls #log_no_payment' do
        expect(subject).to receive(:log_no_payment).with(invalid_external_reference, operation_id)
        spree_post :notification, notification_params
      end
    end


  end
end