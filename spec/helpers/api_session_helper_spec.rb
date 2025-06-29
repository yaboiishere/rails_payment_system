require 'rails_helper'

RSpec.describe ApiSessionHelper, type: :helper do
  describe '#jwt_encode' do
    it 'encodes a payload into a JWT token' do
      payload = { user_id: 123 }
      token = helper.jwt_encode(payload)

      expect(token).to be_a(String)
      expect(token.split('.').size).to eq(3) # JWT tokens have 3 parts separated by '.'
    end
  end

  describe '#jwt_decode' do
    let(:payload) { { user_id: 456 } }
    let(:token) { helper.jwt_encode(payload) }

    context 'with a valid token' do
      it 'decodes the token and returns success' do
        result = helper.jwt_decode(token)

        expect(result[:success?]).to be true
        expect(result[:token]["payload"]).to include("user_id" => 456)
      end
    end

    context 'with an invalid token' do
      it 'returns success? false and an error message' do
        invalid_token = 'invalid.token.here'
        result = helper.jwt_decode(invalid_token)

        expect(result[:success?]).to be false
        expect(result[:error]).to be_a(String)
        expect(result[:error]).to include('Invalid segment encoding')
      end
    end
  end
end
