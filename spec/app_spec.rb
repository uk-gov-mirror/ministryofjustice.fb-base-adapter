require 'spec_helper'
require 'jwe'
require 'securerandom'

describe '/submission' do
  let(:encryption_key) { SecureRandom.uuid[0..15] }
  let(:payload) { "{\"foo\": \"bar\"}" }
  let(:encrypted_payload) { JWE.encrypt(payload, encryption_key, alg: 'dir') }

  context 'when posting submission' do
    before do
      allow(ENV).to receive(:[]).with('ENCRYPTION_KEY').and_return(encryption_key)
    end

    it 'returns the submission payload' do
      post '/submission', encrypted_payload

      get '/submission'
      expect(last_response.body).to eq(payload)
    end
  end
end
