# open-api

**A flexible, inline [OpenAPI](https://github.com/OAI/OpenAPI-Specification) documentation solution
for your Rails-based REST API.**

[OpenAPI](https://github.com/OAI/OpenAPI-Specification) (formerly Swagger) is a popular,
JSON-based, language-agnostic standard for documenting a REST API.  It's quickly becoming the
industry-leading appraoch for describing REST API's of all shapes and sizes.

However, maintaining your own lengthy, stand-alone JSON documentation alongside your Rails API
source code is tedious and error-prone process to say the least.  Here's why using the open-api gem
is better:

+ The open-api gem merges documentation details you provide with API metadata supplied by the
  Rails framework itself, reducing your documentation effort and helping to maintain the accuracy
  of your documentation over time.
+ Your API documentation details live inline right alongside your API source code.  As your API
  changes, locating and updating documentation affected by those changes becomes a far easier task.
+ Metadata inheritance and intelligent merging rules miminize the need to document anything more
  than once, further reducing the development and maintenance burden associated with your API
  documentation.
+ Metadata that's not directly interpreted by open-api is generally passed through to the output
  JSON intact.  As the OpenAPI standard evolves, you won't be limited to using OpenAPI features the
  gem was explicitly written to manage.

## Table of Contents

## Installation

Put this in your Gemfile:

``` ruby
gem 'open-api'
```
## Configuration

Configuration for the open-api gem is performed using an `open_api.rb` initializer in your
`config/initializers` subdirectory.  A sample initializer follows:

``` ruby
OpenApi.configure do |config|

  # Default base path(s), used to scan Rails routes for API endpoints.
  config.base_paths = ['/widget-api/v1']

  # General information about your API.
  config.info = {
      title: 'Acme Widget API',
      description: "Documentation of the Acme's Widget API service",
      version: '1.0.0',
      terms_of_service: 'https://www.acme.com/widget-api/terms_of_service',

      contact: {
          name: 'Acme Corporation API Team',
          url: 'http://www.acme.com/widget-api',
          email: 'widget-api-support@acme.com'
      },

      license: {
          name: 'Apache 2.0',
          url: 'http://www.apache.org/licenses/LICENSE-2.0.html'
      }
  }

  # Default output file path for your generated Open API JSON document.
  config.output_file_path = Rails.root.join('apidoc', 'api-docs.json')
end
```

For details regarding content you may include in the "info" section of your API documentation, see
the[OpenAPI specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#infoObject).


## Describing Endpoints

### Controller-Level Metadata

Controller-level metadata is Open API documentation metadata common to all endpoints for a
controller, as well as any endpoints associated with that controller's subclasses.  Below is an
example of how characteristics common to all endpoints in an API might be defined in a base API
controller:
``` ruby
    class BaseApiController < ActionController::Base

      # Include once in your base API controller class
      include OpenApi::Controller

      open_api_controller \
          query_string: {
            access_token: {
              type: :string,
              description: 'OAuth 2 access token query parameter',
              required: false
            }
          },
          headers: {
              'X-Access-Token' => {
                type: :string,
                description: 'OAuth 2 access token HTTP header',
                required: false
              }
          },
          responses: {
              200 => { description: 'Successful' },
              401 => { description: 'Invalid request' },
              403 => { description: 'Not authorized' }
          }
```

Another common use of `api_controller` is to define a tag for all endpoints associated with a
specific controller:
``` ruby
class WidgetController < BaseApiController

  open_api_controller \
    tag: {
        name: 'Widgets',
        description: 'Manage the widgets associated with your user account'
    }
```
Note that, in the example above, any documentation metadata specified for `BaseApiController` is
inherited for endpoints defined in `WidgetController`.  If the same metadata key is defined for both
controllers, the child controller's metadata will override the superclass' for that key.

Note also that the process of merging metadata in a class hierarchy isn't as simple as doing a
top-level merge or recursive merge for metadata belonging to the classes in that hierarchy.  The
merge process can vary depending on the sort of metadata being merged.  For example, when two query
string parameter lists are merged amongst classes in a hierarchy, the query string entries will be
merged recursively.  This might, for example, allow a description to be amended in a child
controller to a query string parameter defined in a base controller.  For other metadata, the
collection value of a parent controller might be entirely replaced.


## Describing Objects
## Generating Documentation

Generate OpenApi (Swagger) JSON by running the following:

    rake open_api:docs

Optionally, you may specify the base path and output file:

    rake open_api:docs[/api/v1,/home/myhome/api-v1.json]
