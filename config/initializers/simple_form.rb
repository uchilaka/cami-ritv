# frozen_string_literal: true
#
# Uncomment this and change the path if necessary to include your own
# components.
# See https://github.com/heartcombo/simple_form#custom-components to know
# more about custom components.
# Dir[Rails.root.join('lib/components/**/*.rb')].each { |f| require f }
#
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Wrappers are used by the form builder to generate a
  # complete input. You can remove any component from the
  # wrapper, change the order or even add your own to the
  # stack. The options given below are used to wrap the
  # whole input.
  config.wrappers :default, class: 'mx-auto' do |b|
    ## Extensions enabled by default
    # Any of these extensions can be disabled for a
    # given input by passing: `f.input EXTENSION_NAME => false`.
    # You can make any of these extensions optional by
    # renaming `b.use` to `b.optional`.

    # Determines whether to use HTML5 (:email, :url, ...)
    # and required attributes
    b.use :html5

    # Calculates placeholders automatically from I18n
    # You can also pass a string as f.input placeholder: "Placeholder"
    b.use :placeholder

    ## Optional extensions
    # They are disabled unless you pass `f.input EXTENSION_NAME => true`
    # to the input. If so, they will retrieve the values from the model
    # if any exists. If you want to enable any of those
    # extensions by default, you can change `b.optional` to `b.use`.

    # Calculates maxlength from length validations for string inputs
    # and/or database column lengths
    b.optional :maxlength

    # Calculate minlength from length validations for string inputs
    b.optional :minlength

    # Calculates pattern from format validations for string inputs
    b.optional :pattern

    # Calculates min and max from length validations for numeric inputs
    b.optional :min_max

    # Calculates readonly automatically from readonly attributes
    b.optional :readonly

    ## Inputs
    b.use :label,
          class: 'block mb-2 label dark:text-white',
          error_class: 'text-red-700 dark:text-red-500'
    b.use :input,
          class: 'rounded-md block w-full p-2.5 border dark:text-white dark:bg-gray-700',
          label_class: 'block mb-2 label dark:text-white',
          error_class: [
            'is-invalid bg-red-50 dark:bg-gray-700',
            'border-red-500 focus:ring-red-500',
            'focus:border-red-500 dark:border-red-500',
            'text-red-900 dark:text-red-500',
            'placeholder-red-700 dark:placeholder-red-500',
          ].join(' '),
          # hint_class: 'mt-2 text-sm text-gray-500 dark:text-gray-300',
          valid_class: [
            'is-valid bg-green-50 dark:bg-gray-700',
            'text-green-900 dark:text-green-400',
            'placeholder-green-700 dark:placeholder-green-500',
            'focus:ring-green-500 focus:border-green-500',
            'border-green-500 dark:border-green-500',
          ].join(' ')
    b.use :hint, wrap_with: { tag: :em, class: 'hint mt-2 text-sm text-gray-500 dark:text-gray-300' }
    b.use :error, wrap_with: { tag: :span, class: 'error mt-2 text-sm text-red-900 dark:text-red-500' }

    ## full_messages_for
    # If you want to display the full error message for the attribute, you can
    # use the component :full_error, like:
    #
    # b.use :full_error, wrap_with: { tag: :span, class: :error }
  end

  config.wrappers :inline_checkbox, tag: 'div', class: 'flex items-center space-x-2' do |b|
    b.use :input,
          class: 'w-4 h-4 border border-default-medium rounded-xs bg-neutral-secondary-medium focus:ring-2 focus:ring-brand-soft',
          error_class: [
            'is-invalid bg-red-50 dark:bg-gray-700',
            'border-red-500 focus:ring-red-500',
            'focus:border-red-500 dark:border-red-500',
            'text-red-900 dark:text-red-500',
            'placeholder-red-700 dark:placeholder-red-500',
          ].join(' '),
          hint_class: 'mt-2 text-sm text-gray-500 dark:text-gray-300',
          valid_class: [
            'is-valid bg-green-50 dark:bg-gray-700',
            'text-green-900 dark:text-green-400',
            'placeholder-green-700 dark:placeholder-green-500',
            'focus:ring-green-500 focus:border-green-500',
            'border-green-500 dark:border-green-500',
          ].join(' ')
    b.use :label,
          class: 'label select-none font-medium',
          error_class: 'text-red-700 dark:text-red-500'
    b.use :error, wrap_with: { tag: :span, class: 'error mt-2 text-sm text-red-900 dark:text-red-500' }
    b.use :hint, wrap_with: { tag: :em, class: 'hint mt-2 text-sm text-gray-500 dark:text-gray-300' }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  # Defaults to :nested for bootstrap config.
  #   inline: input + label
  #   nested: label > input
  #config.boolean_style = :nested

  # Default class for buttons
  config.button_class = [
    'bg-white dark:bg-gray-800',
    'text-gray-900 dark:text-white border border-gray-300',
    'focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100',
    'font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2',
    'dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700',
  ].join(' ')

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # Use :to_sentence to list all errors for each field.
  # config.error_method = :first

  # Default tag used for error notification helper.
  config.error_notification_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = 'text-sm text-red-800 rounded-lg bg-red-50 dark:bg-gray-800 dark:text-red-400'

  # Series of attempts to detect a default label method for collection.
  # config.collection_label_methods = [ :to_label, :name, :title, :to_s ]

  # Series of attempts to detect a default value method for collection.
  # config.collection_value_methods = [ :id, :to_s ]

  # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
  # config.collection_wrapper_tag = nil

  # You can define the class to use on all collection wrappers. Defaulting to none.
  # config.collection_wrapper_class = nil

  # You can wrap each item in a collection of radio/check boxes with a tag,
  # defaulting to :span.
  # config.item_wrapper_tag = :span

  # You can define a class to use in all item wrappers. Defaulting to none.
  # config.item_wrapper_class = nil

  # How the label text should be generated altogether with the required text.
  # config.label_text = lambda { |label, required, explicit_label| "#{required} #{label}" }

  # You can define the class to use on all labels. Default is nil.
  # config.label_class = 'block mb-2 label dark:text-white'

  # You can define the default class to be used on forms. Can be overridden
  # with `html: { :class }`. Defaulting to none.
  # config.default_form_class = nil

  # You can define which elements should obtain additional classes
  # config.generate_additional_classes_for = [:wrapper, :label, :input]

  # Whether attributes are required by default (or not). Default is true.
  # config.required_by_default = true

  # Tell browsers whether to use the native HTML5 validations (novalidate form option).
  # These validations are enabled in SimpleForm's internal config but disabled by default
  # in this configuration, which is recommended due to some quirks from different browsers.
  # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
  # change this configuration to true.
  config.browser_validations = false

  # Custom mappings for input types. This should be a hash containing a regexp
  # to match as key, and the input type that will be used when the field name
  # matches the regexp as value.
  # config.input_mappings = { /count/ => :integer }

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper that will be used for all inputs with specified type.
  # config.wrapper_mappings = { string: :prepend }

  # Namespaces where SimpleForm should look for custom input classes that
  # override default inputs.
  # config.custom_inputs_namespaces << "CustomInputs"

  # Default priority for time_zone inputs.
  # config.time_zone_priority = nil

  # Default priority for country inputs.
  # config.country_priority = nil

  # When false, do not use translations for labels.
  # config.translate_labels = true

  # Automatically discover new inputs in Rails' autoload path.
  # config.inputs_discovery = true

  # Cache SimpleForm inputs discovery
  # config.cache_discovery = !Rails.env.development?

  # Default class for inputs
  # config.input_class = 'rounded-md block w-full p-2.5 border dark:text-white dark:bg-gray-700'

  # Define the default class of the input wrapper of the boolean input.
  # config.boolean_label_class = 'checkbox'

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  # config.include_default_input_wrapper_class = true

  # Defines which i18n scope will be used in Simple Form.
  # config.i18n_scope = 'simple_form'

  # Defines validation classes to the input_field. By default it's nil.
  # config.input_field_valid_class = 'is-valid'
  # config.input_field_error_class = 'is-invalid'
end
