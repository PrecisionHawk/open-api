module OpenApi
  module Controller
    def self.included(base)
      base.send(:include, OpenApi::Endpoints::Controller)
      base.send(:include, OpenApi::Objects::Controller)
      base.send(:include, OpenApi::Tags::Controller)
    end
  end
end
