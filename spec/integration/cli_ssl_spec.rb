require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface, with SSL", mri_only: true, skip_travis: true, skip_windows: true, skip_gha_linux: true do

  include Pact::IntegrationTestSupport

  before(:all) do
    clear_dirs
  end

  it "should respond with SSL" do
    @pid = start_server 4343, '--ssl', false
    wait_until_server_started 4343, true
  end


  it "sets the X-Pact-Mock-Service-Location header with https" do
    @pid = start_server 4343, '--ssl', false
    wait_until_server_started 4343, true
    response = connect_via_ssl 4343
    expect(response.headers['X-Pact-Mock-Service-Location']).to eq 'https://0.0.0.0:4343'
  end

  it "should accept a sslcert and sslkey" do
    path = "#{Dir.pwd}/spec/support/ssl/"
    @pid = start_server 4343, '--ssl --sslcert "' + path + 'server.crt" --sslkey "' + path + 'server.key"', false
    wait_until_server_started 4343, true
    response = connect_via_ssl 4343
    expect(response.headers['X-Pact-Mock-Service-Location']).to eq 'https://0.0.0.0:4343'
  end

  after do
    kill_server @pid
  end

end
