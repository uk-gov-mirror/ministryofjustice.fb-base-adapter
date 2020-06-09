require 'sinatra'
require 'json'
require 'sinatra/json'
require 'pry'
require 'jwe'

PAYLOAD_CONTENT_FILE = 'tmp/payload_content.json'

post "/submission" do
  payload = request.body.read
  File.write(PAYLOAD_CONTENT_FILE, payload)
end

get "/submission" do
  encrypted_payload = File.read(PAYLOAD_CONTENT_FILE)
  JWE.decrypt(encrypted_payload, ENV['ENCRYPTION_KEY'])
end
