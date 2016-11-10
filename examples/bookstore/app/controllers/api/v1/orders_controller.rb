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

      ORDER_PAYLOAD = {
          id: :integer,
          user: {
              id: :integer,
              username: :string,
              email: :string
          }.freeze,
          orderItems: {
              type: :array,
              items: { '$ref' => :order_item_payload }
          }.freeze,
          orderTotal: :float,
          createdAt: :dateTime,
          updatedAt: :dateTime
      }.freeze
      open_api_object :order_payload, ORDER_PAYLOAD

      ORDER_ITEM_PAYLOAD = {
          id: :integer,
          productId: :integer,
          sku: :string,
          quantity: :integer,
          price: :float,
          tax: :float,
          shipping: :float,
          total: :float
      }.freeze
      open_api_object :order_item_payload, ORDER_ITEM_PAYLOAD

      open_api_object :order_object_response, COMMON_RESPONSE_STATUS.merge(order: ORDER_PAYLOAD)
      open_api_object :order_list_response, COMMON_RESPONSE_STATUS.merge(
          orders: { type: :array, items: { '$ref' => :order_payload }, required: true }
      ).merge(COMMON_PAGINATION_STATUS)

      # GET /api/v1/orders endpoint OpenAPI doc metadata and implementation
      open_api_action :index, response: :order_object_response,
          description: 'Retrieve list of available orders',
          responses: { 200 => { schema: :order_list_response } }
      def index
        fail NotImplementedError
      end

      # GET /api/v1/orders/:order_id endpoint OpenAPI doc metadata and implementation
      open_api_action :show,
          description: 'Retrieve details for a specific order',
          responses: { 200 => { schema: :order_object_response } }
      def show
        fail NotImplementedError
      end

      # POST /api/v1/orders endpoint OpenAPI doc metadata and implementation
      open_api_action :create,
          description: 'Create a new order',
          body: { description: 'Payload', schema: :order_payload },
          responses: { 200 => { schema: :order_object_response } }
      def create
        fail NotImplementedError
      end

      # PATCH/PUT api/v1/orders/:order_id endpoint OpenAPI doc metadata and implementation
      open_api_action :update,
          description: 'Update an existing order',
          body: { description: 'Payload', schema: :order_payload },
          responses: { 200 => { schema: :order_object_response } }
      def update
        fail NotImplementedError
      end

      # DELETE /api/v1/orders/:order_id endpoint OpenAPI doc metadata and implementation
      open_api_action :destroy,
          description: 'Delete an existing order',
          responses: { 200 => { schema: :order_object_response } }
      def destroy
        fail NotImplementedError
      end
    end
  end
end
