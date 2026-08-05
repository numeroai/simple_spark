require 'spec_helper'

describe SimpleSpark::Endpoints::RecipientValidation do
  describe :batch do
    it 'posts the emails and returns the inner results array' do
      verdict = { 'email' => 'a@x.com', 'valid' => true, 'result' => 'valid', 'reason' => '',
                  'delivery_confidence' => 92, 'is_role' => false, 'is_disposable' => false,
                  'is_free' => false, 'did_you_mean' => '' }
      client = double(:client)
      expect(client).to receive(:call)
        .with(method: :post, path: 'recipient-validation/batch', body_values: { emails: ['a@x.com'] })
        .and_return('results' => [verdict])
      endpoint = SimpleSpark::Endpoints::RecipientValidation.new(client)
      expect(endpoint.batch(['a@x.com'])).to eq([verdict])
    end
  end

  describe :single do
    it 'gets the URL-encoded address and returns the verdict' do
      verdict = { 'result' => 'valid', 'valid' => true }
      # real client so url_encode runs; call is stubbed so no network
      client = SimpleSpark::Client.new(api_key: 'mykey')
      expect(client).to receive(:call)
        .with(method: :get, path: 'recipient-validation/single/user%2Btag%40example.com')
        .and_return(verdict)
      endpoint = SimpleSpark::Endpoints::RecipientValidation.new(client)
      expect(endpoint.single('user+tag@example.com')).to eq(verdict)
    end
  end
end
