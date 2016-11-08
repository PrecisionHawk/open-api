module Api
  module V1
    class BooksController < Api::V1::BaseController

      # OpenAPI metadata describing the collective set of endpoints defined in this controller
      open_api_controller(
          tag: {
              name: 'Books',
              description: 'Comprehensive list of available books'
          }
      )

      # GET /api/v1/books endpoint OpenAPI doc metadata and implementation
      open_api_action :index,
          description: 'Retrieve list of available books'
      def index
        fail NotImplementedError
      end

      # GET /api/v1/books/:book_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific book'
      def show
        fail NotImplementedError
      end

      # POST /api/v1/books endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new book'
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/books/:book_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing book'
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/books/:book_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing book'
      def destroy
        fail NotImplementedError
      end
    end
  end
end
