module SimpleSpark
  module Endpoints
    # Provides access to the /templates endpoint
    # @note See: https://developers.sparkpost.com/api/#/reference/templates
    # @note Sample Template
    #   { "id"=>"102293692714480130", "name"=>"Summer Sale!", "description"=>"", "published"=>false, "options"=>{},
    #    "last_update_time"=>"2016-03-02T22:49:23+00:00",
    #    "content"=>{"from"=>"marketing@yourdomain.com", "subject"=>"Summer deals", "html"=>"<b>Check out these deals!</b>"} }
    class Templates
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      # Lists the most recent version of each template in your account.
      # @return [Array] a list of Template hash objects
      # @note See: https://developers.sparkpost.com/api/#/reference/templates/create-and-list
      def list
        @client.call(method: :get, path: 'templates')
      end

      # Create a template by providing values for the template object.
      # @param values [Hash] containing the properties. At a minimum, the "name" and "content"
      #   fields are required, where content must contain the "from", "subject", and at
      #   least one of "html" or "text" fields.
      # @return [boolean] true if success
      # @note See: https://developers.sparkpost.com/api/#/reference/templates/create-and-list
      def create(values)
        @client.call(method: :post, path: 'templates', body_values: values)
      end

      # Retrieve a Template by its ID
      # @param id [String] the Unique Template ID to retrieve
      # @param draft [boolean] If true, returns the most recent draft template.
      #   If false, returns the most recent published template.
      #   If not provided, returns the most recent template version regardless of draft or published.
      # @return [Hash] the Template object
      # @note https://developers.sparkpost.com/api/#/reference/templates/retrieve
      def retrieve(id, draft = nil)
        path = "templates/#{id}"
        query_params = draft.nil? ? {} : { draft: draft }
        @client.call(method: :get, path: path, query_values: query_params)
      end

      # Update a Template by its ID
      # @param id [String] the Unique Template ID to update
      # @param values [Hash] the values to update the template with
      # @param update_published [boolean] If true, directly overwrite the existing published template. If false, create a new draft.
      #   If this template isn't yet published, setting to 'true' will result in a NotFound error
      #
      # @note See: https://developers.sparkpost.com/api/#/reference/templates/update
      def update(id, values, update_published = false)
        @client.call(method: :put, path: "templates/#{id}", body_values: values,  query_values: { update_published: update_published })
      end

      # Preview a Template by its ID
      # @param id [String] the Unique Template ID to preview
      # @param substitutions [Hash] the values to update the template with. Must contain a key 'substitution_data'
      #    { "substitution_data" => { "name" => "Natalie", "age" => 35, "member" => true }
      # @param draft [boolean] If true, returns the most recent draft template.
      #   If false, returns the most recent published template.
      #   If not provided, returns the most recent template version regardless of draft or published.
      #
      # @note See: https://developers.sparkpost.com/api/#/reference/templates/preview
      def preview(id, substitutions, draft = nil)
        query_params = draft.nil? ? {} : { draft: draft }
        @client.call(method: :post, path: "templates/#{id}/preview", body_values: substitutions, query_values: query_params)
      end

      #
      # Preview a Template inline
      # @param values [Hash]
      #
      # @param values[:substitution_data] [Hash] the values to update the template with.
      #    { "substitution_data" => { "name" => "Natalie", "age" => 35, "member" => true }
      #
      # @param values[:content] [Hash] the from, subject and html values. Must contain a key 'substitution_data'
      #   { "content": { "from": "sandbox@sparkpostbox.com", "subject": "Summer deals for {{name}}", "html": "<b>Check out these deals {{name}}!</b>" } }
      #
      # @note See: https://developers.sparkpost.com/api/templates/#templates-post-preview-an-inline-templat
      def preview_inline(values)
        @client.call(method: :post, path: 'utils/content-previewer', body_values: values)
      end

      # Delete a Template by its ID
      # @param id [String] the Unique Template ID to delete
      #
      # @note See: https://developers.sparkpost.com/api/#/reference/templates/delete
      def delete(id)
        @client.call(method: :delete, path: "templates/#{id}")
      end
    end
  end
end
