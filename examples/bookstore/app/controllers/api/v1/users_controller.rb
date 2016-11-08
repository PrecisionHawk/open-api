module Api
  module V1
    class UsersController < Api::V1::BaseController

      # OpenAPI metadata describing the collective set of endpoints defined in this controller
      open_api_controller(
          tag: {
              name: 'Users',
              description: 'Comprehensive list of available users'
          }
      )

      # GET /api/v1/users endpoint OpenAPI doc metadata and implementation
      open_api_action :index,
          description: 'Retrieve list of available users'
      def index
        render_collection collection_query, base_api_options
      end

      # GET /api/v1/users/:user_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific user'
      def show
        render_object object_query.first, base_api_options
      end

      # POST /api/v1/users endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new user'
      def create
        do_create base_api_options
      end

      # PATCH/PUT api/v1/users/:user_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing user'
      def update
        do_update object_query, base_api_options
      end

      # DELETE /api/v1/users/:user_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing user'
      def destroy
        do_destroy object_query, base_api_options
      end
    end
  end
end
