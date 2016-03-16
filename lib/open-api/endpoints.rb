module OpenApi
  class Endpoints
    class << self
      METADATA_MERGE = {
          tags: (lambda do |tags, merge_tags|
            tags ||= {}
            return tags if merge_tags.nil?
            fail 'Expected tags as an Array!' unless merge_tags.is_a?(Array)
            tags + merge_tags
          end),
          headers: (lambda do |headers, merge_headers, opts|
            OpenApi::Utils.verify_and_merge_hash(headers, merge_headers, 'header parameters', opts)
          end),
          path_params: (lambda do |path_params, merge_path_params, opts|
            OpenApi::Utils.verify_and_merge_hash(path_params, merge_path_params, 'path parameters',
                opts)
          end),
          query_string: (lambda do |query_string, merge_query_string, opts|
            OpenApi::Utils.verify_and_merge_hash(query_string, merge_query_string,
                'query string parameters', opts)
          end),
          form_data: (lambda do |form_data, merge_form_data, opts|
            OpenApi::Utils.verify_and_merge_hash(form_data, merge_form_data, 'form data parameters',
                opts)
          end),
          body: (lambda do |body_data, merge_body_data, opts|
            OpenApi::Utils.verify_and_merge_hash(body_data, merge_body_data, 'body', opts)
          end),
          responses: (lambda do |responses, merge_responses, opts|
            merge_responses = Hash[(merge_responses.map do |key, hash|
              fail "Invalid response code #{key}" if key.to_s != key.to_i.to_s
              [key.to_i, hash]
            end)]
            OpenApi::Utils.verify_and_merge_hash(responses, merge_responses, 'responses', opts)
          end)
      }

      def merge_metadata(metadata, merge_metadata, opts = {})
        if (body_value = merge_metadata[:body]).respond_to?(:to_sym)
          merge_metadata = merge_metadata.merge(body: { schema: { :'$ref' => body_value.to_sym } })
        end
        if merge_metadata.include?(:children)
          merge_metadata = merge_metadata.reject { |k, _v| k == :children }
        end
        OpenApi::Utils.merge_hash(metadata, merge_metadata, opts.merge(merge_by: METADATA_MERGE))
      end

      def relative_path(path, base_path)
        return path if path.blank? || base_path.blank?
        relative_path = path[base_path.length..-1]
        relative_path = "/#{relative_path}" unless relative_path.starts_with?('/')
        relative_path
      end

      def verb_key(route_wrapper)
        route_wrapper.verb.to_s.downcase
      end

      def find_matching_routes(base_path, opts = {})
        path_filter = opts[:path_filter]
        if path_filter.is_a?(String) && !path_filter.starts_with?('/')
          path_filter = "/#{path_filter}"
        end
        matching_routes = []
        Rails.application.routes.routes.each do |route|
          route_wrapper = ActionDispatch::Routing::RouteWrapper.new(route)
          if (path = route_wrapper.path.to_s).starts_with?(base_path)
            next unless check_path_filter(route, relative_path(path, base_path), path_filter, opts)
            matching_routes << route_wrapper
            next
          end
        end
        matching_routes
      end

      def check_path_filter(route, rel_path, path_filter, opts = {})
        return true unless path_filter.present?
        return rel_path == path_filter if path_filter.is_a?(String)
        return rel_path =~ path_filter if path_filter.is_a?(Regexp)
        return path_filter.include?(rel_path) if path_filter.is_a?(Array)
        if path_filter.respond_to?(:call) && path_filter.respond_to?(:parameters)
          route_opts = opts.merge(route: route, controller: route.defaults[:controller],
              action: route.defaults[:action])
          rslt = path_filter.send(*([:call, rel_path, route_opts][0..path_filter.parameters.size]))
          return rslt ? true : false
        end
        false
      end

      def build_parameter_metadata(endpoint_metadata)
        parameters = {}
        parameters = (parameters.is_a?(Array) ? parameters : []) +
            param_array(endpoint_metadata.delete(:headers), :header) +
            param_array(endpoint_metadata.delete(:path_params), :path) +
            param_array(endpoint_metadata.delete(:query_string), :query) +
            param_array(endpoint_metadata.delete(:form_data), :form_data)
        if (body_param = endpoint_metadata.delete(:body)).is_a?(Hash)
          parameters += param_array({ body: body_param }, :body)
        end
        return unless parameters.present?
        endpoint_metadata[:parameters] = OpenApi::Utils.camelize_metadata(parameters, end_depth: 3)
      end

      private

      def param_array(hash, param_in)
        return [] if hash.nil?
        fail "Expected Hash for parameter type '#{param_in}'!" unless hash.is_a?(Hash)
        hash.map do |key, value|
          { name: key, in: OpenApi::Utils.camelize_key(param_in) }.merge(
              value.reject { |k, _v| [:name, :in].include?(k) })
        end
      end
    end

    module Controller
      module ClassMethods
        def open_api_path(path, metadata = nil)
          @open_api_path_metadata ||= {} if metadata.present?
          OpenApi::Utils.metadata_by_string_or_regexp(@open_api_path_metadata, path, metadata,
              arg_name: 'path')
        end

        def open_api_path_param(path_param, param_metadata)
          regexp = %r{(\A|\/)\:#{path_param}(\Z|\/)|\(\.\:#{path_param}\)}
          open_api_path regexp, path_params: {
              path_param.to_s => { type: :integer, required: true }.merge(param_metadata)
          }
        end

        def open_api_controller(metadata = nil)
          return (@open_api_controller_metadata || {}).deep_dup if metadata.blank?
          fail 'Expected Hash argument for open_api_controller()!' unless metadata.is_a?(Hash)
          OpenApi::Endpoints.merge_metadata(@open_api_controller_metadata ||= {}, metadata)
          nil
        end

        def open_api_action(action, metadata = nil)
          @open_api_action_metadata ||= {} if metadata.present?
          OpenApi::Utils.metadata_by_string_or_regexp(@open_api_action_metadata, action, metadata,
              arg_name: 'action')
        end

        def open_api_endpoint_metadata(action, path, opts = {})
          path = OpenApi::Endpoints.relative_path(path, opts[:base_path])
          controller_class_hierarchy = OpenApi::Utils.controller_class_hierarchy(self)
          aggr_controller_metadata = {}
          controller_class_hierarchy.each do |controller_class|
            OpenApi::Endpoints.merge_metadata(aggr_controller_metadata,
                controller_class.send(:open_api_controller), opts)
          end
          aggr_path_metadata = {}
          controller_class_hierarchy.each do |controller_class|
            OpenApi::Endpoints.merge_metadata(aggr_path_metadata,
                controller_class.send(:open_api_path, path), opts)
          end
          aggr_action_metadata = {}
          controller_class_hierarchy.each do |controller_class|
            OpenApi::Endpoints.merge_metadata(aggr_action_metadata,
                controller_class.send(:open_api_action, action), opts)
          end
          OpenApi::Endpoints.merge_metadata(aggr_controller_metadata,
              OpenApi::Endpoints.merge_metadata(aggr_action_metadata, aggr_path_metadata,
                  opts), opts)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
