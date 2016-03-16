module OpenApi
  class Utils
    class << self
      def controller_class_hierarchy(controller_class)
        controller_class_hierarchy = [controller_class]
        loop do
          controller_class = controller_class.superclass
          break if controller_class.nil? || !controller_class.respond_to?(:open_api_controller)
          controller_class_hierarchy << controller_class
        end
        controller_class_hierarchy
      end

      def verify_and_merge_hash(hash, merge_hash, hash_desc, opts = {})
        return (hash || {}) if merge_hash.nil?
        fail "Expected #{hash_desc} in the form of a Hash!" unless merge_hash.is_a?(Hash)
        merge_hash(hash, merge_hash, opts)
      end

      def merge_hash(hash, merge_hash, opts = {})
        hash ||= {}
        return hash if merge_hash.nil?
        fail 'Expected Hash!' unless merge_hash.is_a?(Hash)
        merge_hash.each do |key, value|
          if hash.include?(key)
            merge_hash_entry(hash, key, value, opts)
          elsif !value.nil?
            hash[key] = value
          end
        end
        hash
      end

      def camelize_metadata(metadata, opts = {})
        if (start_depth = opts[:start_depth].to_i) > 0
          start_depth -= 1
          if start_depth > 0
            opts = opts.merge(start_depth: start_depth)
          else
            (opts = opts.dup).delete(:start_depth)
          end
        end
        if (end_depth = opts[:end_depth]).present?
          end_depth -= 1
          return metadata if end_depth <= 0
          opts = opts.merge(end_depth: end_depth)
        end
        if metadata.is_a?(Hash)
          Hash[(metadata.map do |k, v|
            [start_depth > 0 ? k : camelize_key(k), camelize_metadata(v, opts)]
          end)]
        elsif metadata.is_a?(Array)
          metadata.map { |v| camelize_metadata(v, opts) }
        else
          metadata
        end
      end

      def camelize_key(key)
        key.to_s.camelize(:lower).to_sym
      end

      def metadata_by_string_or_regexp(metadata_map, string_or_regexp, metadata, opts = {})
        arg_ref = "#{opts[:arg_name]} argument".strip
        if metadata.blank?
          fail "Valid #{arg_ref} required!" unless string_or_regexp.respond_to?(:to_sym)
          response_metadata = {}
          (metadata_map || {}).each do |key, item_metadata|
            if key.is_a?(Regexp)
              next unless string_or_regexp =~ key
            else
              next unless string_or_regexp.casecmp(key) == 0
            end
            OpenApi::Endpoints.merge_metadata(response_metadata, item_metadata.deep_dup)
          end
          return response_metadata
        end
        unless string_or_regexp.respond_to?(:to_sym) || string_or_regexp.is_a?(Regexp)
          fail "Valid #{arg_ref} required!"
        end
        fail 'Expected Hash metadata_map argument!' unless metadata_map.is_a?(Hash)
        fail 'Expected Hash metadata argument!' unless metadata.is_a?(Hash)
        string_or_regexp = string_or_regexp.to_s unless string_or_regexp.is_a?(Regexp)
        existing_metadata = (metadata_map[string_or_regexp] ||= {})
        OpenApi::Endpoints.merge_metadata(existing_metadata, metadata)
        nil
      end

      def open_api_type_and_format(type_name)
        case type_name.to_s.downcase.to_sym
        when :integer then   [:integer, :int32]
        when :long then      [:integer, :int]
        when :float then     [:number,  :float]
        when :double then    [:number,  :double]
        when :string then    [:string,  nil]
        when :byte then      [:string,  :byte]
        when :binary then    [:string,  :binary]
        when :boolean then   [:boolean, nil]
        when :date then      [:string,  :date]
        when :datetime then  [:string,  :'date-time']
        when :password then  [:string,  :password]
        else                 [nil, nil]
        end
      end

      private

      def merge_hash_entry(hash, key, value, opts)
        merge_by_hash = opts[:merge_by] || {}
        if (merge_by = merge_by_hash[key]).present?
          if merge_by.respond_to?(:call) && merge_by.respond_to?(:parameters)
            if (param_count = merge_by.parameters.size) < 2
              fail "Expected 2+ parameters (existing/merged values) for '#{key}' merge_by proc!"
            end
            merge_by.send(*([:call, hash[key], value, opts][0..param_count]))
          end
        elsif hash[key].is_a?(Hash) && value.is_a?(Hash)
          if opts[:recursive_merge]
            merge_hash(hash[key], value, opts)
          else
            hash[key].merge!(value)
          end
        elsif value.nil?
          hash.delete(key)
        else
          hash[key] = value
        end
      end
    end
  end
end
