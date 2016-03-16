module OpenApi
  module Objects
    class << self
      METADATA_MERGE = {
          properties: (lambda do |properties, merge_properties, opts|
            OpenApi::Utils.verify_and_merge_hash(properties, merge_properties, 'properties',
                opts.merge(recursive_merge: true))
          end)
      }

      def merge_metadata(metadata, merge_metadata, opts = {})
        OpenApi::Utils.merge_hash(metadata, merge_metadata, opts.merge(merge_by: METADATA_MERGE))
      end

      def resolve_refs(metadata, definitions, controller, opts = {})
        resolve_proc = -> (object_name) { controller.open_api_object_metadata(object_name) }
        if metadata.is_a?(Hash)
          Hash[(metadata.map do |key, value|
            value = resolve_refs(value, definitions, controller, opts)
            if ['schema', 'items', '$ref'].include?(key.to_s) && value.respond_to?(:to_sym) &&
                !(object = resolve_ref(value.to_sym, resolve_proc)).nil?
              fail 'Expected Hash for definitions!' unless definitions.is_a?(Hash)
              object = resolve_refs(object, definitions, controller, opts)
              add_definition(definitions, value.to_sym, object)
              next [:'$ref', "#/definitions/#{value}"] if key.to_s == '$ref'
              next [key.to_sym, { :'$ref' => "#/definitions/#{value}" }]
            end
            [key, value]
          end)]
        elsif metadata.is_a?(Array)
          metadata.map do |elem|
            resolve_refs(elem, definitions, controller, opts)
          end
        else
          metadata
        end
      end

      private

      def resolve_ref(key, resolve_proc, opts = {})
        unless resolve_proc.respond_to?(:call) &&
            resolve_proc.respond_to?(:parameters)
          fail 'Expected proc/lambda for resolve_proc!'
        end
        proc_param_count = resolve_proc.parameters.size
        fail 'Expected 1+ parameters (object name) for resolve_proc!' if proc_param_count < 1
        object = resolve_proc.send(*([:call, key, opts][0..proc_param_count]))
        return nil if object.nil?
        fail 'Expected hash result from resolve_proc!' unless object.is_a?(Hash)
        object
      end

      def add_definition(definitions, key, object)
        return if object.nil?
        json = object.to_json
        retry_index = 0
        loop do
          if definitions.include?(key)
            break if definitions[key].to_json == json
            retry_index += 1
            key = "#{key}#{retry_index}".to_sym
          else
            definitions[key] = object
            break
          end
        end
      end
    end

    module Controller
      module ClassMethods
        def open_api_objects(metadata = nil)
          return (@open_api_objects_metadata || {}).deep_dup if metadata.blank?
          fail 'Expected Hash argument for open_api_objects()!' unless metadata.is_a?(Hash)
          metadata.each do |object_key, object_metadata|
            open_api_object(object_key, object_metadata)
          end
          nil
        end

        def open_api_object(object_key, metadata = nil)
          fail 'Valid object argument required!' unless object_key.respond_to?(:to_sym)
          return (@open_api_objects_metadata || {})[object_key.to_sym].deep_dup if metadata.blank?
          fail 'Expected Hash argument for open_api_object()!' unless metadata.is_a?(Hash)
          metadata = expand_nested_object_metadata(metadata)
          object_metadata = ((@open_api_objects_metadata ||= {})[object_key.to_sym] ||= {})
          OpenApi::Objects.merge_metadata(object_metadata, metadata)
          nil
        end

        def expand_nested_object_metadata(metadata)
          unless metadata[:type].respond_to?(:to_sym) && metadata[:type].to_sym == :object
            metadata = { type: :object, properties: metadata }
          end
          required_attrs = (metadata[:required] || []).map(&:to_sym)
          if (properties = metadata[:properties]).is_a?(Hash) && properties.present?
            metadata = metadata.dup
            properties = Hash[(properties.map do |name, property|
              property = expand_nested_object_property(name, property, required_attrs)
              [name, property]
            end)]
            metadata[:properties] = properties
          end
          metadata[:required] = required_attrs.uniq if required_attrs.present?
          metadata
        end

        def expand_nested_object_property(name, property, required_attrs)
          if property.is_a?(Hash)
            required = property[:required]
            if required.nil?
              required_attrs << name.to_sym # Presume required if required option not spec'd
            elsif [TrueClass, FalseClass].include?(required.class)
              required_attrs << name.to_sym if property.delete(:required)
            end
            unless property.blank? || property[:type].respond_to?(:to_sym)
              property = expand_nested_object_metadata(property)
            end
          else
            api_type, api_format = OpenApi::Utils.open_api_type_and_format(property)
            if api_type.nil?
              property = { type: :object, '$ref' => property }
            elsif api_format.present?
              property = { type: api_type, format: api_format }
            else
              property = { type: api_type }
            end
            required_attrs << name.to_sym # Presume required if required option not spec'd
          end
          property
        end

        def open_api_object_metadata(object_key, opts = {})
          controller_class_hierarchy = OpenApi::Utils.controller_class_hierarchy(self)
          aggr_object_metadata = {}
          controller_class_hierarchy.each do |controller_class|
            OpenApi::Objects.merge_metadata(aggr_object_metadata,
                controller_class.send(:open_api_object, object_key), opts)
          end
          aggr_object_metadata
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
