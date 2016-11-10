module Api
  module V1
    class AuthorsController < Api::V1::BaseController

      # OpenAPI metadata describing the collective set of endpoints defined in this controller
      open_api_controller(
          tag: {
              name: 'Authors',
              description: 'View and manage book authors'
          }
      )

      AUTHOR_PAYLOAD = {
          id: :integer,
          displayName: :string,
          firstName: :string,
          lastName: :string,
          primaryGenre: {
              id: :integer,
              name: :string
          }.freeze,
          createdAt: :dateTime,
          updatedAt: :dateTime
      }.freeze
      open_api_object :author_payload, AUTHOR_PAYLOAD

      open_api_object :author_object_response, COMMON_RESPONSE_STATUS.merge(author: AUTHOR_PAYLOAD)
      open_api_object :author_list_response, COMMON_RESPONSE_STATUS.merge(
            authors: { type: :array, items: { '$ref' => :author_payload }, required: true }
          ).merge(COMMON_PAGINATION_STATUS)

      # GET /api/v1/authors endpoint OpenAPI doc metadata and implementation
      open_api_action :index, response: :author_object_response,
          description: 'Retrieve list of available authors',
          responses: { 200 => { schema: :author_list_response } }
      def index
        fail NotImplementedError
      end

      # GET /api/v1/authors/:author_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific author',
          responses: { 200 => { schema: :author_object_response } }
      def show
        fail NotImplementedError
      end

      # POST /api/v1/authors endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new author',
          body: { description: 'Payload', schema: :author_payload },
          responses: { 200 => { schema: :author_object_response } }
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/authors/:author_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing author',
          body: { description: 'Payload', schema: :author_payload },
          responses: { 200 => { schema: :author_object_response } }
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/authors/:author_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing author',
          responses: { 200 => { schema: :author_object_response } }
      def destroy
        fail NotImplementedError
      end
    end
  end
end
