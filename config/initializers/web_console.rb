# frozen_string_literal: true

unless Rails.env.test?
  Rails.application.configure do
    # Note on issues with calling the web console:
    # https://github.com/rails/web-console?tab=readme-ov-file#why-does-the-console-only-appear-on-error-pages-but-not-when-i-call-it
    config.middleware.insert(0, Rack::Deflater)

    # Enable web console for all IP addresses (see https://stackoverflow.com/a/71292229)
    # To enable all IP v6 addresses, use '::/0'
    # config.web_console.permissions = '0.0.0.0/0'
    config.web_console.permissions = VirtualOfficeManager.web_console_permissions

    # When a console cannot be shown for a given IP address or content type, messages
    # such as the following is printed in the server logs:
    # > Cannot render console from 192.168.1.133! Allowed networks: 127.0.0.0/127.255.255.255, ::1
    #
    # If you don't want to see this message anymore, set this option to false:
    config.web_console.whiny_requests = true
  end
end
