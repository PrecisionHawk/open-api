module Api
  module V1
    class BooksController < Api::V1::BaseController

      # OpenAPI metadata describing the collective set of endpoints defined in this controller
      open_api_controller(
          tag: {
              name: 'Books',
              description: 'View and manage books'
          }
      )

      BOOK_PAYLOAD = {
          id: :integer,
          name: :string,
          description: :string,
          isbn: :string,
          price: :float,
          authors: {
              type: :array,
              items: { '$ref' => :book_author_payload }
          }.freeze,
          primaryGenre: {
              id: :integer,
              name: :string
          }.freeze,
          createdAt: :dateTime,
          updatedAt: :dateTime
      }.freeze
      open_api_object :book_payload, BOOK_PAYLOAD

      BOOK_AUTHOR_PAYLOAD = {
          id: :integer,
          displayName: :string,
          firstName: :string,
          lastName: :string
      }.freeze
      open_api_object :book_author_payload, BOOK_AUTHOR_PAYLOAD

      open_api_object :book_object_response, COMMON_RESPONSE_STATUS.merge(book: BOOK_PAYLOAD)
      open_api_object :book_list_response, COMMON_RESPONSE_STATUS.merge(
          books: { type: :array, items: { '$ref' => :book_payload }, required: true }
      ).merge(COMMON_PAGINATION_STATUS)

      # GET /api/v1/books endpoint OpenAPI doc metadata and implementation
      open_api_action :index, response: :book_object_response,
          description: 'Retrieve list of available books',
          responses: { 200 => { schema: :book_list_response } }
      def index
        fail NotImplementedError
      end

      # GET /api/v1/books/:book_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific book',
          responses: { 200 => { schema: :book_object_response } }
      def show
        fail NotImplementedError
      end

      # POST /api/v1/books endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new book',
          body: { description: 'Payload', schema: :book_payload },
          responses: { 200 => { schema: :book_object_response } }
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/books/:book_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing book',
          body: { description: 'Payload', schema: :book_payload },
          responses: { 200 => { schema: :book_object_response } }
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/books/:book_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing book',
          responses: { 200 => { schema: :book_object_response } }
      def destroy
        fail NotImplementedError
      end
    end
  end
end
