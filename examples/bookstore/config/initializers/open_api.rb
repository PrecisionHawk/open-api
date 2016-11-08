OpenApi.configure do |config|

  # Include ADMIN=1 in your rake task to generate internal API
  api_type = ENV['ADMIN'].present? && ENV['ADMIN'].to_s != '0' ? 'INTERNAL' : 'Public'

  config.base_paths = ['/api/v1']
  config.info = {
      title: "OpenAPI Book Store #{api_type} API",
      description: "OpenAPI Book Store #{api_type} REST API",
      version: '1.0.0',
      terms_of_service: 'https://www.openapibookstore.com/terms_of_service',
      contact: {
          name: 'Open API Book Store Support Team',
          url: 'http://www.openapibookstore.com',
          email: 'support@openapibookstore.com'
      },
      license: {
          name: 'Apache 2.0',
          url: 'http://www.apache.org/licenses/LICENSE-2.0.html'
      }
  }
  config.output_file_path = Rails.root.join('doc', 'api-docs.json')
end
