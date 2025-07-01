# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Transaction', type: :request do
  describe 'POST /api/v1/transactions' do
    let(:merchant1) { create(:merchant) }
    let(:merchant2) { create(:merchant) }

    let(:valid_params) do
      {
        amount: 100.0,
        customer_email: 'customer@example.com',
        customer_phone: '+15551234567',
        transaction_type: 'authorize',
        merchant_id: merchant1.id
      }
    end

    let(:valid_charge_params) do
      valid_params.merge(
        transaction_type: 'charge',
      )
    end

    let(:valid_refund_params) do
      valid_params.merge(
        transaction_type: 'refund',
      )
    end

    let(:valid_reversal_params) do
      valid_params.merge(
        transaction_type: 'reversal',
        amount: nil
      )
    end

    context 'when merchant creates transaction for self' do
      before do
        @token = create_jwt_token(merchant1)
      end

      it 'creates the transaction successfully' do
        post transaction_index_path, params: valid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('uuid')
        expect(JSON.parse(response.body)).not_to have_key('id')
      end

      it 'creates the transaction successfully with XML' do
        data = valid_params.to_xml(root: 'transaction')
        post transaction_index_path, params: data,
             headers: { 'Authorization' => "Bearer #{@token}",
                        'CONTENT_TYPE' => 'application/xml' }
        expect(response).to have_http_status(:created)
        parsed = Hash.from_xml(response.body)
        expect(parsed['hash']['type']).to eq('authorize')
        expect(parsed['hash']['amount']).to eq(100.0)
        expect(parsed['hash']['merchant_id']).to eq(merchant1.id)
        expect(parsed['hash']).to have_key('uuid')
        expect(parsed['hash']).not_to have_key('id')
      end

      it 'creates subsequent transaction' do
        post transaction_index_path, params: valid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:created)
        parsed_authorize_response = JSON.parse(response.body)
        expect(parsed_authorize_response).to have_key('uuid')
        expect(parsed_authorize_response).not_to have_key('id')
        expect(parsed_authorize_response['type']).to eq('authorize')

        auth_uuid = parsed_authorize_response['uuid']
        valid_charge_params[:parent_transaction_uuid] = auth_uuid
        post transaction_index_path, params: valid_charge_params,
             headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:created)
        parsed_charge_response = JSON.parse(response.body)
        expect(parsed_charge_response).to have_key('uuid')
        expect(parsed_charge_response).not_to have_key('id')
        expect(parsed_charge_response['type']).to eq('charge')
        expect(parsed_charge_response['parent_transaction_uuid']).to eq(auth_uuid)
        expect(parsed_charge_response).not_to have_key('parent_transaction_id')
        expect(parsed_charge_response['amount']).to eq(valid_charge_params[:amount].to_s)

        charge_uuid = parsed_charge_response['uuid']
        valid_refund_params[:parent_transaction_uuid] = charge_uuid
        post transaction_index_path, params: valid_refund_params,
             headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:created)
        parsed_refund_response = JSON.parse(response.body)
        expect(parsed_refund_response).not_to have_key('id')
        expect(parsed_refund_response).to have_key('uuid')
        expect(parsed_refund_response['type']).to eq('refund')
        expect(parsed_refund_response['parent_transaction_uuid']).to eq(charge_uuid)
        expect(parsed_refund_response).not_to have_key('parent_transaction_id')
        expect(parsed_refund_response['amount']).to eq(valid_refund_params[:amount].to_s)

        valid_reversal_params[:parent_transaction_uuid] = auth_uuid
        post transaction_index_path, params: valid_reversal_params,
             headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:created)
        parsed_reversal_response = JSON.parse(response.body)
        expect(parsed_reversal_response).not_to have_key('id')
        expect(parsed_reversal_response).to have_key('uuid')
        expect(parsed_reversal_response['type']).to eq('reversal')
        expect(parsed_reversal_response['parent_transaction_uuid']).to eq(auth_uuid)
        expect(parsed_reversal_response).not_to have_key('parent_transaction_id')
        expect(parsed_reversal_response['amount']).to be_nil
      end

      it 'returns error when parent transaction UUID is the wrong type' do
        post transaction_index_path, params: valid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:created)
        parsed_authorize_response = JSON.parse(response.body)
        expect(parsed_authorize_response).to have_key('uuid')
        expect(parsed_authorize_response).not_to have_key('id')
        expect(parsed_authorize_response['type']).to eq('authorize')

        auth_uuid = parsed_authorize_response['uuid']

        valid_reversal_params[:parent_transaction_uuid] = auth_uuid
        post transaction_index_path, params: valid_reversal_params,
             headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:created)
        parsed_reversal_response = JSON.parse(response.body)
        expect(parsed_reversal_response).not_to have_key('id')
        expect(parsed_reversal_response).to have_key('uuid')
        expect(parsed_reversal_response['type']).to eq('reversal')

        valid_refund_params[:parent_transaction_uuid] = auth_uuid

        post transaction_index_path, params: valid_refund_params,
             headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to have_key('errors')
        errors = parsed_body['errors']

        expect(errors[0]).to include("Parent transaction must be approved")
        expect(errors[1]).to include("Parent transaction is the wrong type")
        expect(errors[2]).to include("Transaction creation failed for ")
      end

      it 'creates a transaction and returns XML successfully' do
        params = valid_params.to_xml(root: 'transaction')
        post transaction_index_path,
             params: params,
             headers: {
               'Authorization' => "Bearer #{@token}",
               'Content-Type' => 'application/xml',
               'Accept' => 'application/xml'
             }

        expect(response).to have_http_status(:created)
        parsed = Hash.from_xml(response.body)

        expect(parsed['hash']['type']).to eq('authorize')
        expect(parsed['hash']['amount']).to eq(100.0)
        expect(parsed['hash']['merchant_id']).to eq(merchant1.id)
        expect(parsed['hash']).to have_key('uuid')
      end

      it 'returns error for invalid transaction type' do
        invalid_params = valid_params.deep_dup
        invalid_params[:transaction_type] = 'invalid_type'

        post transaction_index_path, params: invalid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
        expect(JSON.parse(response.body)['errors']).to include('Invalid transaction type invalid_type. Valid types are: authorize, charge, refund, reversal')
      end

      it 'returns error for invalid transaction type with XML' do
        invalid_params = valid_params.deep_dup
        invalid_params[:transaction_type] = 'invalid_type'
        data = invalid_params.to_xml(root: 'transaction')

        post transaction_index_path, params: data,
             headers: { 'Authorization' => "Bearer #{@token}",
                        'CONTENT_TYPE' => 'application/xml' }

        expect(response).to have_http_status(:unprocessable_entity)
        parsed_body = Hash.from_xml(response.body)
        expect(parsed_body['hash']).to have_key('errors')
        expect(parsed_body['hash']['errors']).to include('Invalid transaction type invalid_type. Valid types are: authorize, charge, refund, reversal')
      end

      it 'returns error for missing required fields' do
        invalid_params = valid_params.deep_dup
        invalid_params.delete(:amount)

        post transaction_index_path, params: invalid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to have_key('errors')
        expect(parsed_body['errors']).to include("Amount must be greater than zero")
      end

      it 'returns error for missing merchant_id, unable to authenticate' do
        invalid_params = valid_params.deep_dup
        invalid_params.delete(:merchant_id)

        post transaction_index_path, params: invalid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:forbidden)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to have_key('error')
        expect(parsed_body['error']).to include("Unauthorized access")
      end

      it 'returns error for missing merchant_id with XML' do
        invalid_params = valid_params.deep_dup
        invalid_params.delete(:merchant_id)
        data = invalid_params.to_xml(root: 'transaction')

        post transaction_index_path, params: data,
             headers: { 'Authorization' => "Bearer #{@token}",
                        'CONTENT_TYPE' => 'application/xml' }

        expect(response).to have_http_status(:forbidden)
        parsed_body = Hash.from_xml(response.body)
        expect(parsed_body['hash']).to have_key('error')
        expect(parsed_body['hash']['error']).to include("Unauthorized access")
      end
    end

    context 'when merchant tries to create transaction for another merchant' do
      before do
        @token = create_jwt_token(merchant2)
      end

      it 'returns forbidden status' do
        post transaction_index_path, params: valid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to have_key('error')
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized access')
      end
    end

    context 'with invalid transaction parameters' do
      before do
        @token = create_jwt_token(merchant1)
      end

      it 'returns unprocessable entity' do
        invalid_params = valid_params.deep_dup
        invalid_params[:amount] = -100 # Invalid amount

        post transaction_index_path, params: invalid_params,
             headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end
end
