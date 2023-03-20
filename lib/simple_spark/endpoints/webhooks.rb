module SimpleSpark
  module Endpoints
    # Provides access to the /webhooks endpoint
    # @note Example webhook
    # @note See: https://developers.sparkpost.com/api/#/reference/webhooks
    class Webhooks
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      # List currently extant webhooks
      # @return [Array] a list of Webhook hash objects
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/list
      def list(timezone = nil)
        query_params = timezone.nil? ? {} : { timezone: timezone }
        @client.call(method: :get, path: 'webhooks', query_values: query_params)
      end

      # Create a webhook
      # @param values [Hash] the values to create the webhook with
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/create
      def create(values)
        @client.call(method: :post, path: 'webhooks', body_values: values)
      end

      # Retrieve details about a webhook by specifying its id
      # @param id [String] the ID of the webhook
      # @return [Hash] an Webhook hash object
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/retrieve
      def retrieve(id)
        @client.call(method: :get, path: "webhooks/#{id}")
      end

      # Update a Webhook by its ID
      # @param id [String] the ID of the webhook
      # @param values [Hash] the values to update the webhook with
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/update-and-delete
      def update(id, values)
        @client.call(method: :put, path: "webhooks/#{id}", body_values: values)
      end

      # Validates a Webhook by sending an example message event batch from the Webhooks API to the target URL
      # @param id [String] the ID of the webhook
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/validate
      def validate(id)
        @client.call(method: :post, path: "webhooks/#{id}/validate")
      end

      # Batch status information
      # @param id [String] the ID of the webhook
      # @return [Array] a list of status hash objects
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/batch-status
      def batch_status(id, limit = nil)
        query_params = limit.nil? ? {} : { limit: limit }
        @client.call(method: :get, path: "webhooks/#{id}/batch-status", query_values: query_params)
      end

      # Returns sample event data
      # @param events [String] Event types for which to get a sample payload
      # @return [Array] a list of sample event hash objects
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/events-samples
      def samples(events = nil)
        query_params = events.nil? ? {} : { events: events }
        @client.call(method: :get, path: 'webhooks/events/samples', query_values: query_params)
      end

      # Returns Returns a list of descriptions of the events, event types, and event fields that
      # could be included in a webhooks batches
      # @return [Array] a list of sample event hash objects
      # @note See: https://developers.sparkpost.com/api/webhooks/#webhooks-get-events-documentation
      def documentation
        @client.call(method: :get, path: 'webhooks/events/documentation', query_values: {})
      end

      # Delete a webhook
      # @param id [String] the ID
      # @note See: https://developers.sparkpost.com/api/#/reference/webhooks/update-and-delete
      def delete(id)
        @client.call(method: :delete, path: "webhooks/#{id}")
      end
    end
  end
end
