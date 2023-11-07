module SimpleSpark
  module Endpoints
    # Provides access to the /sending-ips endpoint
    # @note Example sending ip
    # {
    #   "external_ip": "123.45.67.80",
    #   "hostname": "mta474a.sparkpostmail.com",
    #   "ip_pool": "default"
    # }
    # @note See: https://developers.sparkpost.com/api/sending-ips/
    class SendingIps
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      # Lists your sending ips
      # @return [Array] a list of Sending Ip hash objects
      # @note See: https://developers.sparkpost.com/api/sending-ips/#sending-ips-get-list-all-sending-ips
      def list
        @client.call(method: :get, path: 'sending-ips')
      end

      # Retrieve a sending ip
      # @param ip_name [String] the ip name to retrieve
      # @return [Hash] an Sending Ip hash object
      # @note See: https://developers.sparkpost.com/api/sending-ips/#sending-ips-get-retrieve-a-sending-ip
      def retrieve(ip_name)
        ip_name = @client.url_encode(ip_name)
        @client.call(method: :get, path: "sending-ips/#{ip_name}")
      end

      # Update a Sending Ip by its ip name
      # @param ip_name [String] the ip to update
      # @param values [Hash] the values to update the sending ip with
      #
      # @note See: https://developers.sparkpost.com/api/sending-ips/#sending-ips-put-update-a-sending-ip
      def update(ip_name, values)
        ip_name = @client.url_encode(ip_name)
        @client.call(method: :put, path: "sending-ips/#{ip_name}", body_values: values)
      end
    end
  end
end
