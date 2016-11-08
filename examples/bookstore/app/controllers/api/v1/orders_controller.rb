module Api
  module V1
    class OrdersController < Api::V1::BaseController

      # OpenAPI metadata describing the collective set of endpoints defined in this controller
      open_api_controller(
          tag: {
              name: 'Orders',
              description: 'Comprehensive list of available orders'
          }
      )

      # GET /api/v1/orders endpoint OpenAPI doc metadata and implementation
      open_api_action :index,
          description: 'Retrieve list of available orders'
      def index
        fail NotImplementedError
      end

      # GET /api/v1/orders/:order_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific order'
      def show
        fail NotImplementedError
      end

      # POST /api/v1/orders endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new order'
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/orders/:order_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing order'
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/orders/:order_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing order'
      def destroy
        fail NotImplementedError
      end
    end
  end
end
