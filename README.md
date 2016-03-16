#  open-api - Inline OpenAPI (Swagger) 2 documentation for your Rails-based API

[The OpenAPI (Swagger) 2.0 specification](https://github.com/OAI/OpenAPI-Specification) outlines
a popular, JSON-based, language-agnostic means for documenting a REST API.  It's quickly becoming
the industry standard for describing REST API's of all shapes and sizes.

However, maintaining a lengthy, independent JSON document alongside your Rails-based API is tedious and
error-prone.  Here's why using open-api is better:

+ The open-api gem combines documentation details you provide with API metadata supplied by the
  Rails framework, reducing your documentation effort and helping ensure consistency between code
  and documentation over time.
+ Documentation is maintained inline right alongside your API source code.  As your API changes, it
  should be readily apparent to developers what documentation will need to be changed along with it.
+ Metadata inheritance and intelligent merging rules miminize the need to document anything more
  than once, further reducing the development and maintenance burden associated with your API
  documentation.
+ Metadata that's not directly interpreted by open-api is generally passed on to the output JSON
  as-is.  As a result, you're not restricted to some subset of the Open API standard that the
  open-api gem explicitly supports.

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

  # Default base path to scan for API endpoints.  The base path also appears in the generated Open
  # API documentation, and can be overridden via rake task argument for multiple API scenarios.
  config.base_path = '/widget-api/v1'

  # Top-level general information about your API.  Note that, as with most metadata specified for
  # the open-api gem, underscored keys are converted to lower-case "camelized" strings.
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
the [OpenAPI specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#infoObject).


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

### Action-Level Metadata

Action-level metadata is metadata common to all endpoints for a specific action, or when used with a
regular expression, all actions who match the regular expression.  It is perhaps the most common way
in which Open API metadata will be defined in your application, and an example of how it might
appear follows:
``` ruby
class WidgetController < BaseApiController

  open_api_action :index,
      description: "Returns a complete list of widgets tied to your user account",
      query_string: {
        include_deleted: {
          type: :boolean,
          description: 'Include deleted widgets'
        }
      },
      responses: {
          200 => { body: 'WidgetCollectionResponse' }
      }
```
Note that any medatadata provided for the endpoint is merged with controller-level metadata when
rendering a response.  If the first example provided in [Controller-Level Metadata](#Controller-Level Metadata)
were implemented in `BaseApiController`, the endpoint documentation would include an access token
header and query string parameter as well as HTTP `200`, `401`, and `403` response descriptions.

## Describing Objects
## Generating Documentation

Generate OpenApi (Swagger) JSON by running the following:

    rake open_api:docs

Optionally, you may specify the base path and output file:

    rake open_api:docs[/api/v1,/home/myhome/api-v1.json]
