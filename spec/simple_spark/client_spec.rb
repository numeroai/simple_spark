require 'spec_helper'
require 'uri'

describe SimpleSpark::Client do
  describe :initialize do
    it 'will raise when no API key provided' do
      expect { SimpleSpark::Client.new }.to raise_error(SimpleSpark::Exceptions::InvalidConfiguration, 'You must provide a SparkPost API key')
    end

    context 'defaults' do
      let(:client) { SimpleSpark::Client.new(api_key: 'mykey') }
      specify { expect(client.instance_variable_get(:@api_key)).to eq('mykey') }
      specify { expect(client.instance_variable_get(:@api_host)).to eq('https://api.sparkpost.com') }
      specify { expect(client.instance_variable_get(:@base_path)).to eq('/api/v1/') }
      specify { expect(client.instance_variable_get(:@session).class).to eq(Excon::Connection) }
      specify { expect(client.instance_variable_get(:@debug)).to eq(false) }
      specify { expect(client.instance_variable_get(:@subaccount_id)).to eq(nil) }
    end

    it 'will use the API key from the ENV var' do
      with_modified_env SPARKPOST_API_KEY: 'mykey' do
        expect(SimpleSpark::Client.new.instance_variable_get(:@api_key)).to eq('mykey')
      end
    end

    it 'will use the base_path provided' do
      expect(SimpleSpark::Client.new(api_key: 'mykey', base_path: 'base').instance_variable_get(:@base_path)).to eq('base')
    end

    it 'will use the debug option provided' do
      expect(SimpleSpark::Client.new(api_key: 'mykey', debug: true).instance_variable_get(:@debug)).to eq(true)
    end

    context 'using the subaccount id provided' do
      let(:subaccount_id) { 'my_subaccount_id' }
      let(:client) { SimpleSpark::Client.new(api_key: 'mykey', subaccount_id: subaccount_id) }
      specify { expect(client.instance_variable_get(:@subaccount_id)).to eq(subaccount_id) }
      specify { expect(client.headers).to include('X-MSYS-SUBACCOUNT' => subaccount_id) }
    end

    context 'using the headers option provided' do
      let(:headers) { { x: 'y' } }
      let(:client) { SimpleSpark::Client.new(api_key: 'mykey', headers: headers) }
      specify { expect(client.instance_variable_get(:@headers)).to eq(headers) }
      specify { expect(client.headers).to include(headers) }

      it 'specified headers will override default constructed ones' do
        client = SimpleSpark::Client.new(api_key: 'mykey', subaccount_id: 'old', headers: { 'X-MSYS-SUBACCOUNT' => 'new' })
        expect(client.headers['X-MSYS-SUBACCOUNT']).to eq('new')
      end
    end

    it 'will raise when headers is not a Hash' do
      expect { SimpleSpark::Client.new(api_key: 'mykey', headers: 'wrong') }.to raise_error(SimpleSpark::Exceptions::InvalidConfiguration, 'The headers options provided must be a valid Hash')
    end

    context 'endpoints' do
      let(:client) { SimpleSpark::Client.new(api_key: 'mykey') }

      context 'account' do
        specify { expect(client.account.class).to eq(SimpleSpark::Endpoints::Account) }
      end

      context 'metrics' do
        specify { expect(client.metrics.class).to eq(SimpleSpark::Endpoints::Metrics) }
      end

      context 'subaccounts' do
        specify { expect(client.subaccounts.class).to eq(SimpleSpark::Endpoints::Subaccounts) }
      end

      context 'inbound_domains' do
        specify { expect(client.inbound_domains.class).to eq(SimpleSpark::Endpoints::InboundDomains) }
      end

      context 'message_events' do
        specify { expect(client.message_events.class).to eq(SimpleSpark::Endpoints::MessageEvents) }
      end

      context 'events' do
        specify { expect(client.events.class).to eq(SimpleSpark::Endpoints::Events) }
      end

      context 'relay_webhooks' do
        specify { expect(client.relay_webhooks.class).to eq(SimpleSpark::Endpoints::RelayWebhooks) }
      end

      context 'sending_domains' do
        specify { expect(client.sending_domains.class).to eq(SimpleSpark::Endpoints::SendingDomains) }
      end

      context 'templates' do
        specify { expect(client.templates.class).to eq(SimpleSpark::Endpoints::Templates) }
      end

      context 'transmissions' do
        specify { expect(client.transmissions.class).to eq(SimpleSpark::Endpoints::Transmissions) }
      end

      context 'webhooks' do
        specify { expect(client.webhooks.class).to eq(SimpleSpark::Endpoints::Webhooks) }
      end

      context 'recipient_lists' do
        specify { expect(client.recipient_lists.class).to eq(SimpleSpark::Endpoints::RecipientLists) }
      end

      context 'recipient_validation' do
        specify { expect(client.recipient_validation.class).to eq(SimpleSpark::Endpoints::RecipientValidation) }
      end

    end
  end

  describe :call do
    let(:client) { SimpleSpark::Client.new(api_key: 'mykey', subaccount_id: '42') }

    before do
      client.instance_variable_set(:@session, Excon.new('https://api.sparkpost.com', mock: true))
    end

    after do
      Excon.stubs.clear
    end

    it 'sends JSON, query values, and authorization headers through Excon' do
      request = nil
      Excon.stub({ method: :post, path: '/api/v1/transmissions' }, lambda { |params|
        request = params
        { status: 200, body: '{"results":{"id":"transmission-id"}}' }
      })

      result = client.call(method: :post, path: 'transmissions',
                           body_values: { content: { subject: 'hello' } },
                           query_values: { num_rcpt_errors: 2 })

      expect(result).to eq('id' => 'transmission-id')
      expect(JSON.parse(request[:body])).to eq('content' => { 'subject' => 'hello' })
      query = request[:query].is_a?(Hash) ? request[:query] : URI.decode_www_form(request[:query]).to_h
      expect(query.transform_keys(&:to_s).transform_values(&:to_s)).to eq('num_rcpt_errors' => '2')
      expect(request[:headers]).to include('Authorization' => 'mykey',
                                           'X-MSYS-SUBACCOUNT' => '42',
                                           'Content-Type' => 'application/json')
    end

    it 'returns the full response when result extraction is disabled' do
      response_body = '{"results":{"count":1},"total":5}'
      Excon.stub({ method: :get, path: '/api/v1/metrics' }, { status: 200, body: response_body })

      expect(client.call(method: :get, path: 'metrics', extract_results: false)).to eq(
        'results' => { 'count' => 1 }, 'total' => 5
      )
    end

    it 'maps API errors to the existing exception classes' do
      errors = [{ 'message' => 'Too many requests', 'code' => 123 }]
      Excon.stub({ method: :get, path: '/api/v1/events' },
                 { status: 429, body: JSON.generate('errors' => errors) })

      expect { client.call(method: :get, path: 'events') }.to raise_error(
        SimpleSpark::Exceptions::ThrottleLimitExceeded, 'Too many requests 429 (Error Code: 123)'
      )
    end

    it 'returns an empty hash for a no-content response' do
      Excon.stub({ method: :delete, path: '/api/v1/transmissions' }, { status: 204, body: '' })

      expect(client.call(method: :delete, path: 'transmissions')).to eq({})
    end

    it 'maps an HTTP 504 response to the gateway timeout exception' do
      Excon.stub({ method: :get, path: '/api/v1/events' }, { status: 504, body: '' })

      expect { client.call(method: :get, path: 'events') }.to raise_error(
        SimpleSpark::Exceptions::GatewayTimeoutExceeded
      )
    end

    it 'maps an Excon timeout to the gateway timeout exception' do
      Excon.stub({ method: :get, path: '/api/v1/events' }, lambda { |_params|
        raise Excon::Errors::Timeout, 'timed out'
      })

      expect { client.call(method: :get, path: 'events') }.to raise_error(
        SimpleSpark::Exceptions::GatewayTimeoutExceeded
      )
    end

    it 'round-trips nested symbol and string keys, numbers, booleans, nil, and arrays' do
      request = nil
      Excon.stub({ method: :post, path: '/api/v1/transmissions' }, lambda { |params|
        request = params
        { status: 200, body: '{"results":{}}' }
      })

      body = {
        options: { open_tracking: true, click_tracking: false, start_time: nil },
        'recipients' => [{ address: { email: 'a@example.com' } }, { 'address' => { 'email' => 'b@example.com' } }],
        content: { subject: 'hello', 'template_id' => 'welcome' },
        num_rcpt_errors: 3,
        rate: 1.5
      }

      client.call(method: :post, path: 'transmissions', body_values: body)

      expect(JSON.parse(request[:body])).to eq(
        'options' => { 'open_tracking' => true, 'click_tracking' => false, 'start_time' => nil },
        'recipients' => [{ 'address' => { 'email' => 'a@example.com' } }, { 'address' => { 'email' => 'b@example.com' } }],
        'content' => { 'subject' => 'hello', 'template_id' => 'welcome' },
        'num_rcpt_errors' => 3,
        'rate' => 1.5
      )
    end

    it 'encodes UTF-8 body content without warnings' do
      request = nil
      Excon.stub({ method: :post, path: '/api/v1/transmissions' }, lambda { |params|
        request = params
        { status: 200, body: '{"results":{}}' }
      })

      client.call(method: :post, path: 'transmissions', body_values: { content: { subject: 'héllo ✓ 日本' } })

      expect(request[:body].encoding).to eq(Encoding::UTF_8)
      expect(JSON.parse(request[:body])).to eq('content' => { 'subject' => 'héllo ✓ 日本' })
    end

    it 'sends no body for an empty body hash' do
      request = nil
      Excon.stub({ method: :get, path: '/api/v1/metrics' }, lambda { |params|
        request = params
        { status: 200, body: '{"results":{}}' }
      })

      client.call(method: :get, path: 'metrics', body_values: {})

      expect(request).not_to have_key(:body)
    end

    it 'surfaces duplicate-key bodies according to the installed json version' do
      Excon.stub({ method: :post, path: '/api/v1/transmissions' }, { status: 200, body: '{"results":{}}' })
      body = { content: { subject: 'a' }, 'content' => { subject: 'b' } }
      call = -> { client.call(method: :post, path: 'transmissions', body_values: body) }

      if Gem::Version.new(JSON::VERSION) >= Gem::Version.new('3.0')
        expect(&call).to raise_error(JSON::GeneratorError)
      else
        expect(&call).not_to raise_error
      end
    end

    it 'returns array results unchanged' do
      Excon.stub({ method: :get, path: '/api/v1/suppression-list' },
                 { status: 200, body: '{"results":[{"recipient":"a@example.com"},{"recipient":"b@example.com"}]}' })

      expect(client.call(method: :get, path: 'suppression-list')).to eq(
        [{ 'recipient' => 'a@example.com' }, { 'recipient' => 'b@example.com' }]
      )
    end

    it 'returns an empty hash when a success response has no results key' do
      Excon.stub({ method: :get, path: '/api/v1/metrics' }, { status: 200, body: '{"links":[]}' })

      expect(client.call(method: :get, path: 'metrics')).to eq({})
    end

    it 'maps a 400 response with a description to BadRequest' do
      errors = [{ 'message' => 'Invalid recipient', 'code' => 5001, 'description' => 'Missing email' }]
      Excon.stub({ method: :post, path: '/api/v1/transmissions' },
                 { status: 400, body: JSON.generate('errors' => errors) })

      expect { client.call(method: :post, path: 'transmissions', body_values: { a: 1 }) }.to raise_error(
        SimpleSpark::Exceptions::BadRequest, 'Invalid recipient 400 (Error Code: 5001): Missing email'
      ) { |e| expect(e.object).to eq(errors) }
    end

    it 'raises a JSON parser error for a non-JSON response body' do
      Excon.stub({ method: :get, path: '/api/v1/events' },
                 { status: 502, body: '<html><body>Bad Gateway</body></html>' })

      expect { client.call(method: :get, path: 'events') }.to raise_error(JSON::ParserError)
    end
  end
end
