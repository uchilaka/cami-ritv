# CAMI > Modeling

## Identity Provider Profiles

```shell
bin/rails g model IdentityProviderProfile \
  user:references provider_name:string verified:boolean \
  email:string unverified_email:string email_verified:boolean \
  given_name:string family_name:string display_name:string \
  image_url:string confirmation_sent_at:timestamp metadata:jsonb \
  --pretend
```

## Great! What else can I do?

`bin/rails g model --help`

### Help output

```shell
2024-11-10 22:52:40.001840 I [82616:17220 redis_connection.rb:15] Sidekiq -- Sidekiq 7.3.5 connecting to Redis with options {:size=>10, :pool_name=>"internal", :url=>"redis://localhost:16079/0"}
Usage:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

Options:
      [--skip-namespace]                                            # Skip namespace (affects only isolated engines)
                                                                    # Default: false
      [--skip-collision-check]                                      # Skip collision check
                                                                    # Default: false
      [--force-plural], [--no-force-plural], [--skip-force-plural]  # Do not singularize the model name, even if it appears plural
                                                                    # Default: false
  -o, --orm=NAME                                                    # ORM to be invoked
                                                                    # Default: active_record

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
  [--fixture], [--no-fixture], [--skip-fixture]  # Indicates when to generate fixture
  [--fixture-replacement=NAME]                   # Fixture replacement to be invoked
                                                 # Default: fabrication

Runtime options:
  -f, [--force]                                      # Overwrite files that already exist
  -p, [--pretend], [--no-pretend], [--skip-pretend]  # Run but do not make any changes
  -q, [--quiet], [--no-quiet], [--skip-quiet]        # Suppress status output
  -s, [--skip], [--no-skip], [--skip-skip]           # Skip files that already exist

Description:
    Generates a new model. Pass the model name, either CamelCased or
    under_scored, and an optional list of attribute pairs as arguments.

    Attribute pairs are field:type arguments specifying the
    model's attributes. Timestamps are added by default, so you don't have to
    specify them by hand as 'created_at:datetime updated_at:datetime'.

    As a special case, specifying 'password:digest' will generate a
    password_digest field of string type, and configure your generated model and
    tests for use with Active Model has_secure_password (assuming the default ORM
    and test framework are being used).

    You don't have to think up every attribute up front, but it helps to
    sketch out a few so you can start working with the model immediately.

    This generator invokes your configured ORM and test framework, which
    defaults to Active Record and TestUnit.

    Finally, if --parent option is given, it's used as superclass of the
    created model. This allows you create Single Table Inheritance models.

    If you pass a namespaced model name (e.g. admin/account or Admin::Account)
    then the generator will create a module with a table_name_prefix method
    to prefix the model's table name with the module name (e.g. admin_accounts)

Available field types:

    Just after the field name you can specify a type like text or boolean.
    It will generate the column with the associated SQL type. For instance:

        `bin/rails generate model post title:string body:text`

    will generate a title column with a varchar type and a body column with a text
    type. If no type is specified the string type will be used by default.
    You can use the following types:

        integer
        primary_key
        decimal
        float
        boolean
        binary
        string
        text
        date
        time
        datetime

    You can also consider `references` as a kind of type. For instance, if you run:

        `bin/rails generate model photo title:string album:references`

    It will generate an `album_id` column. You should generate these kinds of fields when
    you will use a `belongs_to` association, for instance. `references` also supports
    polymorphism, you can enable polymorphism like this:

        `bin/rails generate model product supplier:references{polymorphic}`

    For integer, string, text and binary fields, an integer in curly braces will
    be set as the limit:

        `bin/rails generate model user pseudo:string{30}`

    For decimal, two integers separated by a comma in curly braces will be used
    for precision and scale:

        `bin/rails generate model product 'price:decimal{10,2}'`

    You can add a `:uniq` or `:index` suffix for unique or standard indexes
    respectively:

        `bin/rails generate model user pseudo:string:uniq`
        `bin/rails generate model user pseudo:string:index`

    You can combine any single curly brace option with the index options:

        `bin/rails generate model user username:string{30}:uniq`
        `bin/rails generate model product supplier:references{polymorphic}:index`

    If you require a `password_digest` string column for use with
    has_secure_password, you can specify `password:digest`:

        `bin/rails generate model user password:digest`

    If you require a `token` string column for use with
    has_secure_token, you can specify `auth_token:token`:

        `bin/rails generate model user auth_token:token`

Examples:
    `bin/rails generate model account`

        For Active Record and TestUnit it creates:

            Model:      app/models/account.rb
            Test:       test/models/account_test.rb
            Fixtures:   test/fixtures/accounts.yml
            Migration:  db/migrate/XXX_create_accounts.rb

    `bin/rails generate model post title:string body:text published:boolean`

        Creates a Post model with a string title, text body, and published flag.

    `bin/rails generate model admin/account`

        For Active Record and TestUnit it creates:

            Module:     app/models/admin.rb
            Model:      app/models/admin/account.rb
            Test:       test/models/admin/account_test.rb
            Fixtures:   test/fixtures/admin/accounts.yml
            Migration:  db/migrate/XXX_create_admin_accounts.rb
```
