module SimpleSpark
  module Endpoints
    # Provides access to the /recipient-validation endpoint
    # @note Example validation responses
    #
    # a valid email:
    # {
    #   "results": {
    #     "result": "valid",
    #     "valid": true,
    #     "is_role": false,
    #     "is_disposable": false,
    #     "delivery_confidence": 85
    #     "is_free": true
    #   }
    # }
    #
    # an invalid email:
    # {
    #   "results": {
    #     "valid": false,
    #     "result": "undeliverable",
    #     "reason": "Invalid Domain",
    #     "is_role": false,
    #     "is_disposable": false,
    #     "delivery_confidence": 0
    #     "is_free": false
    #   }
    # }
    # @note See: https://developers.sparkpost.com/api/recipient-validation/#header-validation-object
    class RecipientValidation
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      # Validate a single email
      # @param email_address [String] The email address to validate
      # @return [Hash] a Validation object
      # @note See: https://developers.sparkpost.com/api/recipient-validation/#recipient-validation-get-email-address-validation
      def validate(email_address)
        @client.call(method: :get, path: "recipient-validation/single/#{email_address}")
      end
    end
  end
end
