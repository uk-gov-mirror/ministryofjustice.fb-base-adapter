require 'sinatra'
require 'json'
require 'sinatra/json'
require 'pry'
require 'jwe'

PAYLOAD_CONTENT_FILE = 'tmp/payload_content.json'

post '/submission' do
  payload = request.body.read
  File.write(PAYLOAD_CONTENT_FILE, payload)
end

get '/submission' do
  encrypted_payload = File.read(PAYLOAD_CONTENT_FILE)
  JWE.decrypt(encrypted_payload, ENV['ENCRYPTION_KEY'])
rescue Errno::ENOENT
  status 404
  json({ error: 'Submission not found' })
rescue JWE::InvalidData
  status 400
  json(
    { error: 'Failed to decrypt submission. Is the encryption key correct?' }
  )
end
