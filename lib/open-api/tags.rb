module OpenApi
  class Tags
    class << self
      def merge_metadata(metadata, merge_metadata, opts = {})
        OpenApi::Utils.merge_hash(metadata, merge_metadata, opts.merge(recursive_merge: true))
      end

      def resolve_refs(metadata, tags, controller, opts = {})
        opts = opts.symbolize_keys
        opts[:define_proc] ||=
            -> (tag_name, tag_metadata) { controller.open_api_tag(tag_name, tag_metadata) }
        opts[:resolve_proc] ||=
            -> (tag_name) { controller.open_api_tag_metadata(tag_name) }
        if metadata.is_a?(Hash)
          resolve_hash_refs(metadata, tags, controller, opts)
        elsif metadata.is_a?(Array)
          metadata.map do |elem|
            resolve_refs(elem, tags, controller, opts)
          end
        else
          metadata
        end
      end

      private

      def resolve_hash_refs(hash, tags, controller, opts)
        Hash[(hash.map do |key, value|
          next [key, value] unless %w(tag tags).include?(key.to_s)
          if key.to_s == 'tag'
            values = [value]
          else
            next [key, value] unless value.is_a?(Array)
            values = value
          end
          values = resolve_tag_values(values, tags, controller, opts)
          next values.nil? ? [key, values] : [:tags, values]
        end)]
      end

      def resolve_tag_values(values, tags, controller, opts = {})
        define_proc = opts[:define_proc] ||
            -> (tag_name, metadata) { controller.open_api_tag(tag_name, metadata) }
        resolve_proc = opts[:resolve_proc] ||
            -> (tag_name) { controller.open_api_tag_metadata(tag_name) }
        values = (values.map do |value|
          if value.is_a?(Hash)
            next nil unless value[:name].respond_to?(:to_sym)
            name = value[:name].to_s
            value = value.merge(name: name)
            metadata = define_ref(name, value, define_proc, opts)
            add_tag(tags, name, metadata)
            name
          else
            value.respond_to?(:to_sym) ? value.to_s : nil
          end
        end).compact
        return nil if values.empty?
        values = (values.map do |tag|
          next nil unless tag.respond_to?(:to_sym)
          name = tag.to_s
          metadata = resolve_ref(name, resolve_proc, opts)
          fail 'Expected Hash for metadata!' unless metadata.is_a?(Hash)
          add_tag(tags, name, metadata)
          name
        end).compact
        values
      end

      def resolve_ref(key, resolve_proc, opts = {})
        unless resolve_proc.respond_to?(:call) &&
            resolve_proc.respond_to?(:parameters)
          fail 'Expected proc/lambda for resolve_proc!'
        end
        proc_param_count = resolve_proc.parameters.size
        fail 'Expected 1+ parameters (tag) for resolve_proc!' if proc_param_count < 1
        tag = resolve_proc.send(*([:call, key, opts][0..proc_param_count]))
        return nil if tag.nil?
        fail 'Expected hash result from resolve_proc!' unless tag.is_a?(Hash)
        tag
      end

      def define_ref(key, metadata, define_proc, opts = {})
        unless define_proc.respond_to?(:call) &&
            define_proc.respond_to?(:parameters)
          fail 'Expected proc/lambda for define_proc!'
        end
        proc_param_count = define_proc.parameters.size
        fail 'Expected 2+ parameters (tag, metadata) for define_proc!' if proc_param_count < 1
        tag = define_proc.send(*([:call, key, metadata, opts][0..proc_param_count]))
        return nil if tag.nil?
        fail 'Expected hash result from define_proc!' unless tag.is_a?(Hash)
        tag
      end

      def add_tag(tags, tag, metadata)
        return if metadata.nil?
        json = metadata.to_json
        retry_index = 0
        loop do
          if tags.include?(tag)
            break if tags[tag].to_json == json
            retry_index += 1
            tag = "#{tag} (#{retry_index})".to_s
          else
            tags[tag] = metadata
            break
          end
        end
      end
    end

    module Controller
      module ClassMethods
        def open_api_tags(metadata = nil)
          return (@open_api_tags_metadata || {}).deep_dup if metadata.blank?
          fail 'Expected Hash argument for open_api_tags()!' unless metadata.is_a?(Hash)
          metadata.each { |tag, tag_metadata| open_api_tag(tag, tag_metadata) }
          (@open_api_tags_metadata || {})
          nil
        end

        def open_api_tag(tag, metadata = nil)
          fail 'Valid tag argument required!' unless tag.respond_to?(:to_s)
          return (@open_api_tags_metadata || {})[tag.to_s].deep_dup if metadata.blank?
          fail 'Expected Hash argument for open_api_tag()!' unless metadata.is_a?(Hash)
          metadata = { name: tag.to_s }.merge(metadata) unless metadata.include?(:name)
          tag_metadata = ((@open_api_tags_metadata ||= {})[tag.to_s] ||= {})
          OpenApi::Tags.merge_metadata(tag_metadata, metadata)
          nil
        end

        def open_api_tag_metadata(tag, opts = {})
          controller_class_hierarchy = OpenApi::Utils.controller_class_hierarchy(self)
          aggr_metadata = {}
          controller_class_hierarchy.each do |controller_class|
            OpenApi::Tags.merge_metadata(aggr_metadata,
                controller_class.send(:open_api_tag, tag), opts)
          end
          aggr_metadata
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
