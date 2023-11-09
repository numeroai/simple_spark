module SimpleSpark
  module Endpoints
    # Provides access to the /message-events endpoint
    # @note See: https://developers.sparkpost.com/api/events/
    class Events
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      # Returns sample events
      # @param events [String] Event types for which to get a sample payload, use the Webhooks Events endpoint to list the
      #   available event types, defaults to all event types
      # @return [Array] a list of sample Event hash objects
      # @note See: https://developers.sparkpost.com/api/events/#events-get-events-samples
      def samples(events = nil)
        query_params = events.nil? ? {} : { events: events }
        @client.call(method: :get, path: 'events/message/samples', query_values: query_params)
      end

      # Perform a filtered search for message event data. The response is sorted by descending timestamp.
      # @param params [String] Params to use in the search
      # @return [Array] a list of Event hash objects
      # @note https://developers.sparkpost.com/api/events/#events-get-search-for-message-events
      def search(params = {})
        @client.call(method: :get, path: 'events/message', query_values: params)
      end

      # Perform a filtered search for message event data.
      # The result is not extracted, and the next cursor is parsed for the next api call.
      # @param params [String] Params to use in the search
      # @return [Array] a list of Event hash objects
      # @note https://developers.sparkpost.com/api/events/#events-get-search-for-message-events
      def search_with_pagination(params = {})
        result = @client.call(method: :get, path: 'events/message', query_values: params, extract_results: false)

        # append cursor, to be passed into the next query
        next_url = result.dig('links', 'next')
        if next_url != nil
          result['cursor'] = CGI.parse(URI(next_url).query)['cursor'].first
        end

        result
      end
    end
  end
end
