# rubocop:disable Rails/Output
module OpenApi
  class Generator
    HIDDEN_ROOT_KEYS = [:output_file_path, :base_paths]
    class << self
      def build(opts = {})
        base_paths = find_base_paths(opts)

        doc = OpenApi.global_metadata.reject { |k, _v| HIDDEN_ROOT_KEYS.include?(k.to_sym) }
        doc[:info] = OpenApi::Utils.camelize_metadata(doc[:info]) if doc[:info].is_a?(Hash)

        tags, paths, definitions = build_endpoint_content(base_paths, opts)
        doc[:tags] = OpenApi::Utils.camelize_metadata(tags.values) if tags.present?
        doc[:paths] = OpenApi::Utils.camelize_metadata(paths, start_depth: 2, end_depth: 4)
        doc[:definitions] = OpenApi::Utils.camelize_metadata(definitions, start_depth: 2,
            end_depth: 3)

        doc = OpenApi::Utils.camelize_metadata(doc, end_depth: 2)
        doc[:swagger] = doc[:swagger].to_s if doc.include?(:swagger)

        doc
      end

      def write(opts = {})
        output_file_path = opts[:output_file_path] || OpenApi.global_metadata[:output_file_path]
        unless output_file_path.respond_to?(:to_s) && output_file_path.to_s.present?
          fail 'Missing output file path; Must be passed as output_file_path option, or ' \
              'output_file_path must be configured in the OpenApi initializer ' \
              '(config/initializers/open_api.rb)'
        end

        doc = nil
        File.open(output_file_path.to_s, 'w') do |file|
          file.write JSON.pretty_generate(doc = build(opts))
        end

        doc
      end

      def log_message(level, message, opts = {})
        unless [:debug, :info, :warn, :error, :fatal].include?(level)
          fail "Invalid message level: #{level}"
        end
        if opts[:stdout]
          puts "[#{level}] #{message}"
        else
          Rails.logger.send(level, message.to_s)
        end
      end

      def build_endpoint_content(base_paths, opts = {})
        paths = {}
        tags = {}
        definitions = {}
        common_base_path = find_common_base_path(base_paths)
        global_opts = opts.merge(base_path: common_base_path)
        base_paths.each do |base_path, base_path_opts|
          opts = global_opts.merge(base_path_opts)
          OpenApi::Endpoints.find_matching_routes(base_path, opts).each do |route_wrapper|
            controller_name = (route_wrapper.controller).split('/').map(&:camelize).join('::') +
                'Controller'
            controller = controller_name.constantize
            if controller.nil?
              log_message(:warn, "Can't resolve controller: #{route_wrapper.controller}", opts)
              next
            end
            next unless controller.respond_to?(:open_api_endpoint_metadata)
            endpoint_metadata = controller.open_api_endpoint_metadata(route_wrapper.action,
                route_wrapper.path, opts.merge(base_path: base_path))
            next if endpoint_metadata[:hidden]
            path = add_path(route_wrapper, paths, common_base_path, opts)
            next if path.nil?
            OpenApi::Endpoints.build_parameter_metadata(endpoint_metadata)
            endpoint_metadata = OpenApi::Objects.resolve_refs(endpoint_metadata, definitions,
                controller, opts)
            endpoint_metadata = OpenApi::Tags.resolve_refs(endpoint_metadata, tags, controller,
                opts)
            path[OpenApi::Endpoints.verb_key(route_wrapper)] = endpoint_metadata
          end
        end
        [tags, paths, definitions]
      end

      def add_path(route_wrapper, paths, common_base_path, opts = {})
        relative_path = OpenApi::Endpoints.relative_path(route_wrapper.path.to_s, common_base_path)
        route_wrapper.parts.each do |path_param|
          relative_path = relative_path
              .gsub(%r{(\A|\/)\:(#{path_param})(\Z|\/)}, '\1{\2}\3')
              .gsub(/\(\.\:#{path_param}\)/, ".{#{path_param}}")
        end
        path = (paths[relative_path] ||= {})
        verb_key = OpenApi::Endpoints.verb_key(route_wrapper)
        if path.include?(verb_key)
          base_message = "Warning: Multiple OpenApi::Endpoints match #{route_wrapper.verb} " \
            "#{relative_path} ...  skipping entry for route"
          if route_wrapper.name.present?
            log_message(:warn, "#{base_message} '#{route_wrapper.name}'", opts)
          else
            log_message(:warn, "#{base_message} #{route_wrapper.verb} #{route_wrapper.path}", opts)
          end
          return nil
        end
        path
      end

      def find_base_paths(opts = {})
        base_paths = opts[:base_paths] || OpenApi.global_metadata[:base_paths]
        if base_paths.is_a?(Array)
          base_paths = base_paths.map(&:to_s).reject(&:blank?).uniq
          base_paths = Hash[(base_paths.map do |base_path|
            [base_path.starts_with?('/') ? base_path : "/#{base_path}", {}]
          end)]
        elsif base_paths.is_a?(Hash)
          base_paths = Hash[(base_paths.map do |base_path, api_opts|
            fail "Expected options hash for base path '#{base_path}'" unless api_opts.is_a?(Hash)
            [base_path.starts_with?('/') ? base_path : "/#{base_path}", api_opts]
          end)]
        else
          fail "Invalid value for 'base_paths': Expected Hash or Array"
        end
        if base_paths.blank?
          fail 'Missing API base paths; Must be passed as base_paths option, or base_paths must ' \
              'be configured in the OpenApi initializer (config/initializers/open_api.rb)'
        end
        base_paths
      end

      def find_common_base_path(base_paths)
        return nil if base_paths.blank?
        base_paths = base_paths.keys if base_paths.is_a?(Hash)
        split_paths = base_paths.map do |base_path|
          base_path.split('/').reject(&:blank?)
        end
        path_count = split_paths.length
        first_path = split_paths[0]
        return "/#{first_path.join('/')}" if path_count == 1
        common_elems = 0
        while common_elems < first_path.length
          path_elem_idx = 0
          while path_elem_idx < path_count - 1
            cmp_path = split_paths[path_elem_idx + 1]
            break if cmp_path.length <= common_elems
            break if cmp_path[common_elems] != first_path[common_elems]
            path_elem_idx += 1
          end
          break if path_elem_idx < path_count - 1
          common_elems += 1
        end
        return '/' if common_elems == 0
        "/#{first_path[0..(common_elems - 1)].join('/')}"
      end
    end
  end
end
