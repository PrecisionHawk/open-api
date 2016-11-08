module Api
  module V1
    class BaseController < ActionController::Base
      include OpenApi::Controller

      # OpenAPI documentation metadata shared by all endpoints, including common query string
      #  parameters, HTTP headers, and HTTP response codes.
      open_api_controller(
          query_string: {
              access_token: {
                  type: :string,
                  description: 'OAuth 2 access token query parameter',
                  required: false
              }
          },
          headers: {
              'Authorization' => {
                  type: :string,
                  description: 'Authorization header (format: "Bearer &lt;access token&gt;")',
                  required: false
              }
          },
          responses: {
              200 => { description: 'Successful' },
              400 => { description: 'Not found' },
              401 => { description: 'Invalid request' },
              403 => { description: 'Not authorized (typically missing / invalid access token)' }
          }
      )

      # OpenAPI documentation for common API endpoint path parameters
      open_api_path_param :book_id, description: 'Book identifier'
      open_api_path_param :genre_id, description: 'Genre identifier'
      open_api_path_param :order_id, description: 'Order identifier'
      open_api_path_param :user_id, description: 'User identifier'

    end
  end
end
