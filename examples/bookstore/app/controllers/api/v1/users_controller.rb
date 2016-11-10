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

      USER_PAYLOAD = {
          id: :integer,
          firstName: :string,
          lastName: :string,
          email: :string,
          last_login_at: :dateTime,
          createdAt: :dateTime,
          updatedAt: :dateTime
      }.freeze
      open_api_object :user_payload, USER_PAYLOAD

      open_api_object :user_object_response, COMMON_RESPONSE_STATUS.merge(user: USER_PAYLOAD)
      open_api_object :user_list_response, COMMON_RESPONSE_STATUS.merge(
          users: { type: :array, items: { '$ref' => :user_payload }, required: true }
      ).merge(COMMON_PAGINATION_STATUS)

      # GET /api/v1/users endpoint OpenAPI doc metadata and implementation
      open_api_action :index, response: :user_object_response,
          description: 'Retrieve list of available users',
          responses: { 200 => { schema: :user_list_response } }
      def index
        fail NotImplementedError
      end

      # GET /api/v1/users/:user_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific user',
          responses: { 200 => { schema: :user_object_response } }
      def show
        fail NotImplementedError
      end

      # POST /api/v1/users endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new user',
          body: { description: 'Payload', schema: :user_payload },
          responses: { 200 => { schema: :user_object_response } }
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/users/:user_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing user',
          body: { description: 'Payload', schema: :user_payload },
          responses: { 200 => { schema: :user_object_response } }
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/users/:user_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing user',
          responses: { 200 => { schema: :user_object_response } }
      def destroy
        fail NotImplementedError
      end
    end
  end
end
