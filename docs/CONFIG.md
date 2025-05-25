# CAMI: Configuration

- [CAMI: Configuration](#cami-configuration)
  - [Configuration](#configuration)
    - [Development service ports](#development-service-ports)
    - [Environment variables](#environment-variables)
      - [`LAN_SUBNET_MASK`](#lan_subnet_mask)
      - [`PII_FILTER_ALLOW_ACCESS_TOKENS` (default = `false`)](#pii_filter_allow_access_tokens-default--false)

## Configuration

### Development service ports

<table>
<thead>
    <tr>
        <th>Service</th>
        <th>Port</th>
        <th>Essential</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>Rails</td>
        <td><code>16006</code></td>
        <td style="text-align: center">⭐️</td>
    </tr>
    <tr>
        <td>Postgres (app store)</td>
        <td><code>16032</code></td>
        <td style="text-align: center">⭐️</td>
    </tr>
    <tr>
        <td>Redis</td>
        <td><code>16079</code></td>
        <td style="text-align: center">⭐️</td>
    </tr>
    <tr>
        <td>Redis Commander (admin)</td>
        <td><code>16081</code></td>
        <td></td>
    </tr>
    <tr>
        <td>Mailhog</td>
        <td><code>8025</code></td>
        <td></td>
    </tr>
</table>

### Environment variables

#### `LAN_SUBNET_MASK`

This configuration is intended to give us a way to allow certain app management features
based on the virtual network location of our teams.

Specifically, this `ENV` variable is an override to configure access to the app's
[web console](https://github.com/rails/web-console)
(also see [the docs](https://github.com/rails/web-console?tab=readme-ov-file#configweb_consolepermissions), as well as `VirtualOfficeManager#web_console_permissions`).

The built-in configuration option is to set the following in the corresponding [custom credential file](https://guides.rubyonrails.org/security.html#custom-credentials):

> Tip: run `EDITOR=code bin/thor lx-cli:secrets:edit` in your development environment to edit the credentials file.

```yaml
web_console:
  permissions: 
```

#### `PII_FILTER_ALLOW_ACCESS_TOKENS` (default = `false`)

> **BE CAREFUL NOT TO LEAK SENSITIVE INFORMATION INTO SOURCE CONTROL**. Cassettes are not encrypted and can be read by anyone with access to the repository. Ensure that you do not commit any sensitive information to the repository like access tokens for app integrations.

This configuration is intended to give us a way to allow requests under tests to call through to real world API endpoints that require an access token.

When using this configuration, you should start by ensuring that the `PII_FILTER_ALLOW_ACCESS_TOKENS` is set to `true` in your `.env.test` file.

Next, ensure that you comment out any steps that would normally stub out the request to the API endpoint in your test suite.

Finally, delete the `VCR` cassettes that would normally be used to stub out the request to the API endpoint.

Optionally, you can check for the cassette configuration matching the endpoint you're working on in the `config/vcr.rb` file and set the `record` option to `:new_episodes` or `:all` to ensure that the cassette is updated with the new response.
