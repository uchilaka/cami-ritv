# CAMI > Scaffolding

- [CAMI \> Scaffolding](#cami--scaffolding)
  - [Accounts](#accounts)
    - [Scaffolding output (dry-run)](#scaffolding-output-dry-run)
  - [Invoices](#invoices)
    - [Scaffolding output (dry-run)](#scaffolding-output-dry-run-1)
  - [Sweet! What else does it do?](#sweet-what-else-does-it-do)
    - [Command help output](#command-help-output)

Here's sample code used in setting up the scaffolding for the core features of the app.

> Append `--pretend` to each command to see the output without making any changes.

## Accounts

```shell
bin/rails g scaffold accounts display_name:string slug:string status:integer type:string tax_id:string readme:text --force
```

### Scaffolding output (dry-run)

```shell
2024-11-10 18:47:58.687293 I [47823:17180 redis_connection.rb:15] Sidekiq -- Sidekiq 7.3.5 connecting to Redis with options {:size=>10, :pool_name=>"internal", :url=>"redis://localhost:16079/0"}
[WARNING] The model name 'accounts' was recognized as a plural, using the singular 'account' instead. Override with --force-plural or setup custom inflection rules for this noun before running the generator.
      invoke  active_record
      create    db/migrate/20241110234758_create_accounts.rb
      create    app/models/account.rb
      invoke    rspec
      create      spec/models/account_spec.rb
      invoke      fabrication
      create        spec/fabricators/account_fabricator.rb
      invoke  resource_route
       route    resources :accounts
      invoke  serializer
      create    app/serializers/account_serializer.rb
      invoke  scaffold_controller
      create    app/controllers/accounts_controller.rb
      invoke    tailwindcss
      create      app/views/accounts
      create      app/views/accounts/index.html.erb
      create      app/views/accounts/edit.html.erb
      create      app/views/accounts/show.html.erb
      create      app/views/accounts/new.html.erb
      create      app/views/accounts/_form.html.erb
      create      app/views/accounts/_account.html.erb
      invoke    resource_route
      invoke    rspec
      create      spec/requests/accounts_spec.rb
      create      spec/views/accounts/edit.html.tailwindcss_spec.rb
      create      spec/views/accounts/index.html.tailwindcss_spec.rb
      create      spec/views/accounts/new.html.tailwindcss_spec.rb
      create      spec/views/accounts/show.html.tailwindcss_spec.rb
      create      spec/routing/accounts_routing_spec.rb
      invoke    helper
      create      app/helpers/accounts_helper.rb
      invoke      rspec
      create        spec/helpers/accounts_helper_spec.rb
      invoke    jbuilder
      create      app/views/accounts
      create      app/views/accounts/index.json.jbuilder
      create      app/views/accounts/show.json.jbuilder
      create      app/views/accounts/_account.json.jbuilder
```

## Invoices

```shell
bin/rails g scaffold invoices \
    invoiceable_id:uuid invoiceable_type:string \
    account:references user:references payments:jsonb links:jsonb \
    viewed_by_recipient_at:timestamp updated_accounts_at:timestamp \
    invoice_number:string status:integer issued_at:timestamp \
    due_at:timestamp paid_at:timestamp amount:decimal{10-2} \
    due_amount:decimal{10,2} currency_code:string notes:text \
    --skip --pretend
```

### Scaffolding output (dry-run)

```shell
[WARNING] The model name 'invoices' was recognized as a plural, using the singular 'invoice' instead. Override with --force-plural or setup custom inflection rules for this noun before running the generator.
      invoke  active_record
      create    db/migrate/20241111001034_create_invoices.rb
      create    app/models/invoice.rb
      invoke    rspec
      create      spec/models/invoice_spec.rb
      invoke      fabrication
      create        spec/fabricators/invoice_fabricator.rb
      invoke  resource_route
       route    resources :invoices
      invoke  serializer
      create    app/serializers/invoice_serializer.rb
      invoke  scaffold_controller
      create    app/controllers/invoices_controller.rb
      invoke    tailwindcss
      create      app/views/invoices
      create      app/views/invoices/index.html.erb
      create      app/views/invoices/edit.html.erb
      create      app/views/invoices/show.html.erb
      create      app/views/invoices/new.html.erb
      create      app/views/invoices/_form.html.erb
      create      app/views/invoices/_invoice.html.erb
      invoke    resource_route
      invoke    rspec
      create      spec/requests/invoices_spec.rb
      create      spec/views/invoices/edit.html.tailwindcss_spec.rb
      create      spec/views/invoices/index.html.tailwindcss_spec.rb
      create      spec/views/invoices/new.html.tailwindcss_spec.rb
      create      spec/views/invoices/show.html.tailwindcss_spec.rb
      create      spec/routing/invoices_routing_spec.rb
      invoke    helper
      create      app/helpers/invoices_helper.rb
      invoke      rspec
      create        spec/helpers/invoices_helper_spec.rb
      invoke    jbuilder
      create      app/views/invoices
      create      app/views/invoices/index.json.jbuilder
      create      app/views/invoices/show.json.jbuilder
      create      app/views/invoices/_invoice.json.jbuilder
```

## Sweet! What else does it do?

For the full scaffolding guide:

```shell
bundle exec rails g scaffold --help
```

### Command help output

```shell
Usage:
  bin/rails generate scaffold NAME [field[:type][:index] field[:type][:index]] [options]

Options:
      [--skip-namespace]                                                  # Skip namespace (affects only isolated engines)
                                                                          # Default: false
      [--skip-collision-check]                                            # Skip collision check
                                                                          # Default: false
      [--force-plural], [--no-force-plural], [--skip-force-plural]        # Do not singularize the model name, even if it appears plural
                                                                          # Default: false
  -o, --orm=NAME                                                          # ORM to be invoked
                                                                          # Default: active_record
      [--model-name=MODEL_NAME]                                           # ModelName to be used
      [--resource-route], [--no-resource-route], [--skip-resource-route]  # Indicates when to generate resource route
                                                                          # Default: true
      [--serializer], [--no-serializer], [--skip-serializer]              # Indicates when to generate serializer
                                                                          # Default: true
      [--api], [--no-api], [--skip-api]                                   # Generate API-only controller and tests, with no view templates
                                                                          # Default: false
  -c, --scaffold-controller=NAME                                          # Scaffold controller to be invoked
                                                                          # Default: scaffold_controller

ActiveRecord options:
        [--migration], [--no-migration], [--skip-migration]     # Indicates when to generate migration
                                                                # Default: true
        [--timestamps], [--no-timestamps], [--skip-timestamps]  # Indicates when to generate timestamps
                                                                # Default: true
        [--parent=PARENT]                                       # The parent class for the generated model
                                                                # Default: ApplicationRecord
        [--indexes], [--no-indexes], [--skip-indexes]           # Add indexes for references and belongs_to columns
                                                                # Default: true
        [--primary-key-type=PRIMARY_KEY_TYPE]                   # The type for primary key
                                                                # Default: uuid
  --db, [--database=DATABASE]                                   # The database for your model's migration. By default, the current environment's primary database is used.
  -t,   [--test-framework=NAME]                                 # Test framework to be invoked
                                                                # Default: rspec

Rspec options:
  [--fixture], [--no-fixture], [--skip-fixture]                             # Indicates when to generate fixture
  [--fixture-replacement=NAME]                                              # Fixture replacement to be invoked
                                                                            # Default: fabrication
  [--singleton], [--no-singleton], [--skip-singleton]                       # Supply to create a singleton controller
  [--controller-specs], [--no-controller-specs], [--skip-controller-specs]  # Generate controller specs
                                                                            # Default: false
  [--request-specs], [--no-request-specs], [--skip-request-specs]           # Generate request specs
                                                                            # Default: true
  [--view-specs], [--no-view-specs], [--skip-view-specs]                    # Generate view specs
                                                                            # Default: true
  [--helper-specs], [--no-helper-specs], [--skip-helper-specs]              # Generate helper specs
                                                                            # Default: true
  [--routing-specs], [--no-routing-specs], [--skip-routing-specs]           # Generate routing specs
                                                                            # Default: true

ScaffoldController options:
      [--helper], [--no-helper], [--skip-helper]        # Indicates when to generate helper
                                                        # Default: true
      [--skip-routes]                                   # Don't add routes to config/routes.rb.
  -e, [--template-engine=NAME]                          # Template engine to be invoked
                                                        # Default: tailwindcss
      [--jbuilder], [--no-jbuilder], [--skip-jbuilder]  # Indicates when to generate jbuilder
                                                        # Default: true

Runtime options:
  -f, [--force]                                      # Overwrite files that already exist
  -p, [--pretend], [--no-pretend], [--skip-pretend]  # Run but do not make any changes
  -q, [--quiet], [--no-quiet], [--skip-quiet]        # Suppress status output
  -s, [--skip], [--no-skip], [--skip-skip]           # Skip files that already exist

Description:
    Scaffolds an entire resource, from model and migration to controller and
    views, along with a full test suite. The resource is ready to use as a
    starting point for your RESTful, resource-oriented application.

    Pass the name of the model (in singular form), either CamelCased or
    under_scored, as the first argument, and an optional list of attribute
    pairs.

    Attributes are field arguments specifying the model's attributes. You can
    optionally pass the type and an index to each field. For instance:
    'title body:text tracking_id:integer:uniq' will generate a title field of
    string type, a body with text type and a tracking_id as an integer with an
    unique index. "index" could also be given instead of "uniq" if one desires
    a non unique index.

    As a special case, specifying 'password:digest' will generate a
    password_digest field of string type, and configure your generated model,
    controller, views, and test suite for use with Active Model
    has_secure_password (assuming they are using Rails defaults).

    Timestamps are added by default, so you don't have to specify them by hand
    as 'created_at:datetime updated_at:datetime'.

    You don't have to think up every attribute up front, but it helps to
    sketch out a few so you can start working with the resource immediately.

    For example, 'scaffold post title body:text published:boolean' gives
    you a model with those three attributes, a controller that handles
    the create/show/update/destroy, forms to create and edit your posts, and
    an index that lists them all, as well as a resources :posts declaration
    in config/routes.rb.

    If you want to remove all the generated files, run
    'bin/rails destroy scaffold ModelName'.

Examples:
    `bin/rails generate scaffold post`
    `bin/rails generate scaffold post title:string body:text published:boolean`
    `bin/rails generate scaffold purchase amount:decimal tracking_id:integer:uniq`
    `bin/rails generate scaffold user email:uniq password:digest`
```
