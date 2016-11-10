module Api
  module V1
    class GenresController < Api::V1::BaseController

      # OpenAPI metadata describing the collective set of endpoints defined in this controller
      open_api_controller(
          tag: {
              name: 'Genres',
              description: 'View and manage genre genres'
          }
      )

      GENRE_PAYLOAD = {
          id: :integer,
          name: :string,
          createdAt: :dateTime,
          updatedAt: :dateTime
      }.freeze

      open_api_object :genre_payload, GENRE_PAYLOAD
      open_api_object :genre_object_response, COMMON_RESPONSE_STATUS.merge(genre: GENRE_PAYLOAD)
      open_api_object :genre_list_response, COMMON_RESPONSE_STATUS.merge(
          genres: { type: :array, items: { '$ref' => :genre_payload }, required: true }
      ).merge(COMMON_PAGINATION_STATUS)

      # GET /api/v1/genres endpoint OpenAPI doc metadata and implementation
      open_api_action :index, response: :genre_object_response,
          description: 'Retrieve list of available genres',
          responses: { 200 => { schema: :genre_list_response } }
      def index
        fail NotImplementedError
      end

      # GET /api/v1/genres/:genre_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific genre',
          responses: { 200 => { schema: :genre_object_response } }
      def show
        fail NotImplementedError
      end

      # POST /api/v1/genres endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new genre',
          body: { description: 'Payload', schema: :genre_payload },
          responses: { 200 => { schema: :genre_object_response } }
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/genres/:genre_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing genre',
          body: { description: 'Payload', schema: :genre_payload },
          responses: { 200 => { schema: :genre_object_response } }
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/genres/:genre_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing genre',
          responses: { 200 => { schema: :genre_object_response } }
      def destroy
        fail NotImplementedError
      end
    end
  end
end
