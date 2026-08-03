module SimpleSpark
  module Endpoints
    # Provides access to the /recipient-validation endpoint
    # @note This synchronous batch endpoint is not listed in SparkPost's public API docs
    class RecipientValidation
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      # Validate up to 1,000 email addresses in one call
      # @param emails [Array<String>] the addresses to validate (1..1,000; not de-duplicated server-side)
      # @return [Array<Hash>] one verdict per input address, in input order
      # @note The API responds with results nested one level deeper than the standard
      #   envelope ({"results": {"results": [...]}}) so this method unwraps the inner level
      def batch(emails)
        @client.call(method: :post, path: 'recipient-validation/batch', body_values: { emails: })['results']
      end

      # Validate a single email address
      # @param address [String] the address to validate
      # @return [Hash] the verdict (empty fields omitted by this endpoint)
      def single(address)
        @client.call(method: :get, path: "recipient-validation/single/#{@client.url_encode(address)}")
      end
    end
  end
end
