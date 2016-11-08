module Api
  module V1
    class AuthorsController < Api::V1::BaseController

      # OpenAPI metadata describing the collective set of endpoints defined in this controller
      open_api_controller(
          tag: {
              name: 'Authors',
              description: 'Comprehensive list of available authors'
          }
      )

      # GET /api/v1/authors endpoint OpenAPI doc metadata and implementation
      open_api_action :index,
          description: 'Retrieve list of available authors'
      def index
        fail NotImplementedError
      end

      # GET /api/v1/authors/:author_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific author'
      def show
        fail NotImplementedError
      end

      # POST /api/v1/authors endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new author'
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/authors/:author_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing author'
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/authors/:author_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing author'
      def destroy
        fail NotImplementedError
      end
    end
  end
end
