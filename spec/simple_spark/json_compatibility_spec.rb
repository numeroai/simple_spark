require 'spec_helper'

describe 'JSON compatibility through the client' do
  let(:client) { SimpleSpark::Client.new(api_key: 'mykey') }
  let(:session) { instance_double(Excon::Connection) }

  before do
    client.instance_variable_set(:@session, session)
  end

  def response(status, body)
    double(:response, status: status, body: body)
  end

  [:symbols, :strings].each do |key_style|
    it "sends nested transmission data with #{key_style} as keys without changing the input" do
      values = {
        content: { subject: "Hello Zoë 👋", text: "A quote: \"hello\"\nA slash: \\" },
        recipients: [{ address: { email: 'user+tag@example.com' } }],
        substitution_data: { enabled: true, disabled: false, optional: nil,
                             count: 2, price: 1.25, tags: ['one', 'two'] }
      }
      expected = {
        'content' => { 'subject' => "Hello Zoë 👋", 'text' => "A quote: \"hello\"\nA slash: \\" },
        'recipients' => [{ 'address' => { 'email' => 'user+tag@example.com' } }],
        'substitution_data' => { 'enabled' => true, 'disabled' => false, 'optional' => nil,
                                 'count' => 2, 'price' => 1.25, 'tags' => ['one', 'two'] }
      }
      values = Marshal.load(Marshal.dump(expected)) if key_style == :strings
      original = Marshal.load(Marshal.dump(values))

      expect(session).to receive(:post) do |params|
        expect(params[:path]).to eq('/api/v1/transmissions')
        expect(JSON.parse(params[:body])).to eq(expected)
        response(200, '{"results":{"id":"12345678901234567890"}}')
      end

      expect(client.transmissions.create(values)).to eq('id' => '12345678901234567890')
      expect(values).to eq(original)
    end
  end

  it 'preserves types and Unicode in a results array' do
    expect(session).to receive(:get).and_return(response(200,
      '{"results":[{"id":"12345678901234567890","name":"Zoë 👋","count":12345678901234567890,"rate":1.25,"enabled":true,"disabled":false,"optional":null}]}'))

    expect(client.events.search).to eq([
      { 'id' => '12345678901234567890', 'name' => 'Zoë 👋', 'count' => 12345678901234567890,
        'rate' => 1.25, 'enabled' => true, 'disabled' => false, 'optional' => nil }
    ])
  end

  it 'keeps pagination links and totals when the full response is requested' do
    body = '{"results":[],"total_count":0,"links":{"next":"https://api.sparkpost.com/api/v1/events/message?cursor=a%2Bb"}}'
    expect(session).to receive(:get).and_return(response(200, body))

    expect(client.call(method: :get, path: 'events/message', extract_results: false)).to eq(
      'results' => [], 'total_count' => 0,
      'links' => { 'next' => 'https://api.sparkpost.com/api/v1/events/message?cursor=a%2Bb' }
    )
  end

  it 'preserves error details and partial transmission results' do
    body = '{"errors":[{"message":"Invalid recipient","code":"2000","description":"Address rejected"}],"results":{"id":"123","total_accepted_recipients":1}}'
    expect(session).to receive(:post).and_return(response(422, body))

    expect { client.transmissions.create(content: { template_id: 'welcome' }) }.to raise_error(
      SimpleSpark::Exceptions::UnprocessableEntity
    ) do |error|
      expect(error.message).to eq('Invalid recipient 422 (Error Code: 2000): Address rejected')
      expect(error.object).to eq([
        { 'message' => 'Invalid recipient', 'code' => '2000', 'description' => 'Address rejected' }
      ])
      expect(error.results).to eq('id' => '123', 'total_accepted_recipients' => 1)
      expect(error.transmission_id).to eq('123')
    end
  end

  # These examples document known differences, rather than claiming that JSON 3
  # accepts every payload accepted by JSON 2.
  context 'JSON major version differences' do
    let(:json_three) { Gem::Version.new(JSON::VERSION) >= Gem::Version.new('3.0') }

    it 'rejects colliding string/symbol request keys only on JSON 3' do
      values = { substitution_data: { 'name' => 'Old', :name => 'New' } }

      if json_three
        expect(session).not_to receive(:post)
        expect { client.transmissions.create(values) }.to raise_error(JSON::GeneratorError)
      else
        expect(session).to receive(:post).and_return(response(200, '{"results":{"id":"123"}}'))
        expect(client.transmissions.create(values)).to eq('id' => '123')
      end
    end

    {
      'duplicate keys' => '{"results":{"id":"old","id":"new"}}',
      'JavaScript comments' => '{/* comment */"results":{"id":"new"}}'
    }.each do |feature, body|
      it "rejects responses with #{feature} only on JSON 3" do
        expect(session).to receive(:get).and_return(response(200, body))

        if json_three
          expect { client.call(method: :get, path: 'events/message') }.to raise_error(JSON::ParserError)
        else
          expect(client.call(method: :get, path: 'events/message')).to eq('id' => 'new')
        end
      end
    end
  end
end
