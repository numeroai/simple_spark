module SimpleSpark
  module Endpoints
    # Provides access to the /seeds endpoint
    # @see https://developers.sparkpost.com/api/seed-list/ for more details on the /seeds endpoint

    class Seeds
      attr_accessor :client

      def initialize(client)
        @client = client
      end


      # Retrieve seed list
      # @return [Array] a list of seed list emails
      # @note See: https://developers.sparkpost.com/api/seed-list/
      def retrieve
        @client.call(method: :get, path: 'seeds')
      end

    end
  end
end
