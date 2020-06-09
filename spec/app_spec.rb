require 'spec_helper'
require 'jwe'
require 'securerandom'

describe '/submission' do
  let(:payload) { "{\"foo\": \"bar\"}" }

  context 'when there is a submission' do
    let(:encryption_key) { SecureRandom.uuid[0..15] }
    before do
      allow(ENV).to receive(:[]).with('ENCRYPTION_KEY').and_return(encryption_key)
    end

    context 'when the encryption key is the same as the payload' do
      let(:encrypted_payload) { JWE.encrypt(payload, encryption_key, alg: 'dir') }

      it 'returns the submission payload' do
        post '/submission', encrypted_payload

        get '/submission'
        expect(last_response.body).to eq(payload)
      end
    end

    context 'when the encryption key is NOT the same as the payload' do
      let(:encrypted_payload) { JWE.encrypt(payload, 'a' * 16, alg: 'dir') }
      let(:error) do
        JSON.generate(
          error: 'Failed to decrypt submission. Is the encryption key correct?'
        )
      end

      it 'returns the submission payload' do
        post '/submission', encrypted_payload
        get '/submission'
        expect(last_response.status).to be(400)
        expect(last_response.body).to eq(error)
      end
    end
  end

  context 'when there is no submission' do
    let(:error) { JSON.generate(error: 'Submission not found') }

    before do
      File.delete(PAYLOAD_CONTENT_FILE) if File.exist?(PAYLOAD_CONTENT_FILE)
    end

    it 'returns not found' do
      get '/submission'
      expect(last_response.status).to be(404)
      expect(last_response.body).to eq(error)
    end
  end
end
