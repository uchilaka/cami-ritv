# frozen_string_literal: true

require 'lar_city/cli/utils'

# Set up the baseline .env file for loading application secrets
class EnvSetupCmd < Thor::Group
  namespace :'env-setup'

  no_commands do
    include ::LarCity::CLI::VaultHelpers
    include ::LarCity::CLI::IoHelpers
    include ::LarCity::CLI::OutputHelpers
    include ::LarCity::CLI::Runnable
  end

  define_output_options self, class_options: true
  # Select the source system to use
  class_option  :source,
                type: :array,
                enum: %w[template cli],
                desc: 'The source system(s) to use in setting up ENV variables',
                default: %w[template]
  # Partial option
  class_option :section_slug,
               type: :string,
               desc: 'The section of credentials to provision',
               enum: %w[paypal-integration zoho-crm-integration]

  # --- Sequential steps ---
  def debug_template_file_content
    say_debug <<~DEBUG_MSG

      ******************************************************************
      ******* ENV Template Content (for <project-root>/.env.tpl) *******
      ******************************************************************
      #{template_content}
    DEBUG_MSG
  end

  def write_template_file
    with_interruption_rescue do
      say_info "Writing dotenv template file to #{template_file_path}..."
      return if pretend?

      bytes_written = File.write template_file_path, template_content
      say_debug <<~DEBUG_MSG
        Result of writing dotenv template file to #{template_file_path}: #{bytes_written.inspect}
      DEBUG_MSG
      if bytes_written.positive?
        say_success "Successfully wrote .env template file to #{template_file_path}."
      else
        say_error "Failed to write .env template file to #{template_file_path}."
      end
    end
  end

  def provision_env_file
    if use_explicit_mappings?
      # This process will also check for and fold in source item data if requested
      provision_env_file_from_template
      return
    end

    if pretend?
      say_debug <<~DEBUG_MSG
        Pretending to write provisioned dotenv file to #{output_file_path} with the following content:
        #{template_content}
      DEBUG_MSG
      return
    end

    File.write output_file_path, template_content
  end

  no_commands do
    def provision_env_file_from_template
      require_template_exists!
      require_proton_pass_cli!

      say_info "Provisioning #{output_file_path} file from template at #{template_file_path}..."
      result = run(
        'pass-cli inject',
        "--in-file #{template_file_path}",
        "--out-file #{output_file_path}",
        '--force',
        mock_return: 'injected successfully',
        eval: true
      ) do |line|
        say_debug line
      end
      say_debug <<~DEBUG_MSG
        Result of provisioning dotenv file from template: #{result.inspect}
      DEBUG_MSG

      if %r{injected successfully}.match?(result)
        say_success "Successfully provisioned dotenv file at #{output_file_path} from template."
      elsif %r{requires an authenticated client}.match?(result)
        say_error 'Authentication required to access Proton Vault. Please sign in by running: `pass-cli login`'
      else
        say_error <<~ERROR_MSG
          Failed to provision dotenv file from template. \
          Ensure that you have access to the required secrets in Proton Vault and that your authentication is valid. \
          You can also try running the setup command with --verbose and check for error messages in the result.
        ERROR_MSG
      end
    end

    def template_content
      say_debug <<~DEBUG_MSG
        Fetching environment variable values from Proton Vault to initialize \
        the template and generate the appropriate dotenv file for the current \
        environment.
        |=====================================================================|
        | Detected environment: #{detected_environment}
        | Template: #{template_file_path}
        | Output: #{output_file_path}
        =======================================================================
        ======== IMPORTANT: Ensure Proton Vault Access and Permissions ========
        =======================================================================
        To successfully fetch the required environment variable values, start
        by verifying that you have the necessary access and permissions in
        Proton Vault. You can sign in by running: `pass-cli login`

        Detected environment: #{detected_environment}
        Source Item ID: #{source_item_id}
        Vault Share ID: #{vault_share_id}
        Template path: #{template_file_path}
      DEBUG_MSG

      if File.exist?(dotenv_template_file_path)
        # Process the ERB template file bound to current execution context
        ERB.new(File.read(dotenv_template_file_path)).result(binding)
      else
        shared_header = <<~SHARED_HEADER
          # This file is auto-generated from an ERB template for configuration
          # of secret mappings. The secrets to be provisioned are managed in a
          # Proton Pass Vault.
          #
          # ERB template: #{dotenv_template_file_path}
          #
          # To update the secrets, modify the corresponding item in the vault and
          # re-run this command.
          #
          # Do NOT edit this file directly, as changes will be overwritten.
          # -----------------------------------------------------------------
          # Last generated at: #{Time.current.iso8601}
          # -----------------------------------------------------------------
          export NODE_ENV=#{detected_environment}
        SHARED_HEADER

        file_header = <<~HEADER
          export GITCRYPT_KEY_FILE="config/credentials/git-crypt.key"
          export PORT=16006

          # Was 1 for local debugging
          export RAILS_QUEUE_THREADS=3
          export RAILS_MIN_THREADS=3
          export RAILS_MAX_THREADS=5

          # TODO: Testing between 0 and 2 while observing +[NSCharacterSet initialize] crashing issues on local
          export WEB_CONCURRENCY=0

          # TODO: See https://github.com/railsjazz/rails_live_reload/pull/42
          #export RAILS_LIVE_RELOAD_ENABLED=yes
        HEADER

        file_footer = <<~FOOTER
          export DEFAULT_EMAIL_SENDER="do-not-reply@larcity.tech"
          export INVOICING_EMAIL_SENDER="invoicing@lar.city"
          export MARKETING_EMAIL_SENDER="info@lar.city"

          #export SEMANTIC_LOGGER_STREAMING_ENABLED="yes"
          export APP_DEBUG_MODE=no
          export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
          export DISABLE_SPRING=true

          # Email controls
          #export SEND_EMAILS_ENABLED=yes

          # ETL
          #export UPSERT_INVOICE_BATCH_LIMIT=1000
        FOOTER

        say_warning "⚠️ No environment-specific .env template found at #{dotenv_template_file_path}. Proceeding with default template content."
        build_template_body(shared_header, file_header) do |content|
          [content, file_footer].join("\n")
        end.join("\n")
      end
    end

    private

    def section_only_setup?
      options[:section_slug].present?
    end

    def use_explicit_mappings?
      options[:source].include?('template')
    end

    def use_source_item_data?
      options[:source].include?('cli')
    end

    def dotenv_template_file_path
      Rails.root.join('config', 'dotenvs', ".env.#{detected_environment}.erb").to_s
    end

    def build_template_body(*parts)
      erb_template_array = [*parts.map(&:to_s)]

      if use_explicit_mappings?
        # Provision secrets from ENV variable item in Proton Vault
        erb_template_array << "# #{item_sections['platform']}"
        platform_env_sets.each do |env_key, vault_field|
          vault_field ||= env_key
          erb_template_array <<
            "export #{env_key}=\"{{ pass://#{value_path(vault_share_id, shared_source_item_id, vault_field)} }}\""
        end

        # Provision secrets in other sections
        sections = item_env_sets.map do |_env_key, _vault_field, item_section|
          item_section
        end.flatten.uniq

        say_debug ''
        say_debug '|--------- Sections ---------|'
        say_debug sections.map { |s| "- #{s}" }.join("\n").to_s
        say_debug '|----------------------------|'
        say_debug ''

        # We are currently always generating the ENV file with template mappings included for the
        # "Extra fields" (i.e. non-sectioned items) but the intent is to migrate over to using the
        # sections feature in the Vault to organize as well as annotate the contents in the output
        # file. In the future, we will only support either of the output modes but not both, so the
        # template will be simplified to only support the sectioned output mode.
        erb_template_array << ''
        sections.each do |section|
          next if section == 'platform'

          erb_template_array <<
            "# #{item_sections[section] || section.capitalize}"

          item_env_sets_by(section:).each do |env_key, vault_field, _item_section|
            vault_field ||= env_key
            erb_template_array <<
              "export #{env_key}=\"{{ pass://#{value_path(vault_share_id, source_item_id, vault_field)} }}\""
          end

          erb_template_array << ''
        end
      end

      # Optionally compose data from the source item sections if requested
      erb_template_array << env_content_from_source_item_data if use_source_item_data?

      if block_given?
        yield erb_template_array.join("\n")
      else
        # Return formatted ERB template content as a string
        erb_template_array.join("\n")
      end
    end

    def value_path(*segments)
      segments.compact.join('/')
    end

    alias_method :require_proton_pass_cli!, :require_vault_cli!

    def require_template_exists!
      return if File.exist?(template_file_path)

      say_error "Template file not found at #{template_file_path}. Cannot provision .env file without template."
      raise Thor::Error, "Template file not found at #{template_file_path}"
    end

    def platform_env_sets
      [
        ['RENDER_WORKSPACE_ID', 'Render Workspace ID'],
        ['APP_DEPLOY_PRODUCTION_HOOK_URL', 'Production Deploy Hook URL'],
        ['APP_DEPLOY_STAGING_HOOK_URL', 'Staging Deploy Hook URL'],
      ]
    end

    def item_sections
      {
        'app' => 'Application',
        'cache' => 'Cache store(s)',
        'database' => 'App store configuration',
        'platform' => 'Deployment platform configuration',
        'proxy' => 'Proxy configuration (e.g. ngrok, tailscale)',
        'paypal' => 'PayPal',
        'crm' => 'Zoho CRM',
        'logging' => 'Logging and monitoring',
      }
    end

    def item_env_sets_by(section:)
      item_env_sets.filter do |(_env_key, _vault_field, item_section)|
        item_section == section
      end
    end

    def item_env_sets
      [
        *platform_env_sets.map { |env_key, vault_field| [env_key, vault_field, 'platform'] },
        # ['NGROK_AUTH_TOKEN', nil, 'proxy'],
        # ['CRM_ORG_ID', nil, 'crm'],
      ]
    end

    def output_file_path
      @output_file_path ||=
        begin
          output_filename = ['.env', detected_environment, 'local'].join('.')
          Rails.root.join(output_filename).to_s
        end
    end

    def template_file_path
      @template_path ||= Rails.root.join('.env.tpl').to_s
    end

    def master_key_from_file
      @master_key_from_file ||= (File.read(master_key_path) if File.exist?(master_key_path))
    end

    def master_key_path
      @master_key_path ||= Rails.root.join('config', 'credentials', "#{detected_environment}.key").to_s
    end
  end
end
