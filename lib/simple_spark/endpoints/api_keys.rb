module SimpleSpark
  module Endpoints
    # Provides access to the /api-keys endpoint
    # @note Example sending ip
    # {
    #   "external_ip": "123.45.67.80",
    #   "hostname": "mta474a.sparkpostmail.com",
    #   "ip_pool": "default"
    # }
    # @note See: https://developers.sparkpost.com/api/api-keys/
    class ApiKeys
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      # Create an api key
      # @param grants [Array(String)] The permissions to give to this api key:
      #   acceptable grants are: "metrics/view", "message_events/view", "webhooks/view",
      #                          "webhooks/modify", "templates/view", "templates/modify",
      #                          "templates/preview", "transmissions/view", "transmissions/modify",
      #                          "smtp/inject", "tracking_domains/view", "tracking_domains/manage",
      #                          "sending_domains/manage", "suppression_lists/manage",
      #                          "ab-testing/manage", "data_privacy/manage"
      # @param label [String] The name of the api key
      # @param valid_ips [Array(String)]
      def create(values)
        @client.call(method: :post, path: 'api-keys', body_values: values)
      end

      # Lists your api keys
      # @return [Array] a list of api keys hash objects
      def list
        @client.call(method: :get, path: 'api-keys')
      end

      # Retrieve an api key
      # @param api_key [String] the id of the api key to retrieve
      # @return [Hash] an api key hash object
      def retrieve(api_key)
        @client.call(method: :get, path: "api-keys/#{api_key}")
      end

      # Update an api key
      # @param api_key [String] the id of the api key to update
      # @param values [Hash] the values to update the sending ip with
      #                      must include `label` and `grants`
      def update(api_key, values)
        @client.call(method: :put, path: "api-keys/#{api_key}", body_values: values)
      end

      # Delete an api key
      # @param api_key [String] the id of the api key to update
      def delete(api_key)
        @client.call(method: :delete, path: "api-keys/#{api_key}")
      end
    end
  end
end
