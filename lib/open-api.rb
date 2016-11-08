require 'open-api/controller.rb'
require 'open-api/endpoints.rb'
require 'open-api/generator.rb'
require 'open-api/objects.rb'
require 'open-api/tags.rb'
require 'open-api/utils.rb'
require 'open-api/railtie'

module OpenApi
  class << self
    def configure(metadata = nil, &block)
      return unless metadata.is_a?(Hash) || block_given?
      global_metadata = @open_api_global_metadata || default_global_metadata
      if metadata.is_a?(Hash)
        global_metadata = OpenApi::Utils.merge_hash(global_metadata, metadata)
      end
      if block_given?
        config = OpenStruct.new(global_metadata)
        block.call(config)
        global_metadata = OpenApi::Utils.merge_hash(global_metadata, config.to_h.symbolize_keys)
      end
      @open_api_global_metadata = global_metadata
    end

    def global_metadata
      @open_api_global_metadata || default_global_metadata
    end

    def default_global_metadata
      {
          swagger: 2.0,
          schemes: [:http]
      }
    end
  end
end
