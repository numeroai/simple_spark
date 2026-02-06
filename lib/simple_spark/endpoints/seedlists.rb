module SimpleSpark
  module Endpoints
    # Provides access to the /seeds and /inline-seeds endpoints

    class Seedlists
      attr_accessor :client

      def initialize(client)
        @client = client
      end


      # Retrieve seed list
      # @return [Array] a list of seed list emails
      # @note See: https://developers.sparkpost.com/api/seed-list/
      def retrieve_seeds()
        @client.call(method: :get, path: 'seeds')
      end

      # Returns config details for the authenticated account
      # @return [Hash] a seed config hash object
      # @note See: https://developers.sparkpost.com/api/inline-seeds/
      def get_seed_config()
        @client.call(method: :get, path: 'inline-seeds/config')
      end

      # Create seed config for the authenticated account.
      # @return [Hash] a seed config hash object
      # @note See: https://developers.sparkpost.com/api/inline-seeds/
      def create_seed_config(values)
        @client.call(method: :post, path: 'inline-seeds/config', body_values: values)
      end

      # Create seed config for the authenticated account.
      # @return [Hash] a seed config hash object
      # @note See: https://developers.sparkpost.com/api/inline-seeds/
      def update_seed_config(values)
        @client.call(method: :put, path: 'inline-seeds/config', body_values: values)
      end

    end
  end
end
