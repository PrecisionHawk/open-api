require 'open-api'
require 'rails'

module OpenApi
  class Railtie < Rails::Railtie
    railtie_name 'open-api'

    rake_tasks do
      load 'tasks/open-api.rake'
    end
  end
end
