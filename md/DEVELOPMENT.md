# CAMI: Development guide

- [CAMI: Development guide](#cami-development-guide)
  - [Managing application secrets](#managing-application-secrets)
    - [Testing emails](#testing-emails)
    - [Using NGROK](#using-ngrok)
      - [Update your NGROK token for your app environment](#update-your-ngrok-token-for-your-app-environment)
      - [Instructions for Windows](#instructions-for-windows)
      - [Instructions on macOS](#instructions-on-macos)
    - [Print key file](#print-key-file)
    - [Handling fixture files](#handling-fixture-files)
      - [Sanitizing an existing fixture file](#sanitizing-an-existing-fixture-file)
      - [Converting a JSON fixture file to a YAML fixture file](#converting-a-json-fixture-file-to-a-yaml-fixture-file)

Notes on working with the application in a (local) dev environment.

## Managing application secrets

To edit credentials in your IDE, run the following command in your console:

```shell
bin/thor lx-cli:secrets:edit
```

To view help information about managing application credentials, run the following command in your console:

```shell
bin/rails credentials:help
```

To edit the credentials file for your development environment using the rails credentials scripts
and your command line, run the following code in your console:

```shell
EDITOR=nano bin/rails credentials:edit --environment ${RAILS_ENV:-development}
```

### Testing emails

> To enable email testing, set `SEND_EMAILS_ENABLED=yes` in your `.env.local` file.

To test emails in development, you can use the `Mailhog` service. If you are using the RubyMine configurations you will already have a dockerized `Mailhog` server running in debug mode. Otherwise, to start the service, run the following command in your console:

```shell
docker compose up -d mailhog
```

Your test inbox will be available at `http://localhost:8025`.

### Using NGROK

> Be sure to follow [these instructions](https://ngrok.com/docs/getting-started/) to setup `ngrok` for your local environment.

Run `bin/tunnel` to start up your development tunnel. You'll need this when testing features like SSO that require a public URL.

#### Update your NGROK token for your app environment

You can obtain your auth token from here: <https://dashboard.ngrok.com/get-started/your-authtoken>.

Once you've obtained your token, ensure you set the value in your `.env.local` file with the `NGROK_AUTH_TOKEN` variable.

#### Instructions for Windows

This guide will walk you through completing the following steps:

- Setting up your auth token
- Installing the `nrgok` CLI ([Chocolatey package manager](https://chocolatey.org/install) required)
- Update your PowerShell session execution policy (to allow running scripts)
- Starting your tunnel

First, to set your token for Windows environment, run the following command from a powershell terminal:

```ps1
# See https://ngrok.com/docs/getting-started/#step-2-connect-your-account
ngrok config add-authtoken ${NGROK_AUTH_TOKEN}
```

Next, you want to make sure you've installed the `ngrok` command. The [NGROK getting started guide](https://ngrok.com/docs/getting-started/) will have updates steps but if you use the [Chocolatey package manager](https://chocolatey.org/install), you can run the following command:

```ps1
choco install ngrok
```

Next, run the following command to setup the required execution policy to run `ps1` scripts:

```ps1
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

Next, ensure your powershell profile is setup. This is required for execution policies.

> This powershell script is still in development

```ps1
# Edit your powershell profile config in VSCode
code \\wsl$\Ubuntu-22.04\home\localadmin\repos\@larcity\cami\bin\init-profile.ps1
# Initialize your powershell profile config
powershell.exe -File \\wsl$\Ubuntu-22.04\home\localadmin\repos\@larcity\cami\bin\init-profile.ps1
```

If the script doesn't work, review the contents of the `./cami/bin/init-profile.ps1` file and create the file manually.

Now you should be able to launch your tunnel script from your Windows PowerShell terminal:

```ps1
powershell.exe -File \\wsl$\Ubuntu-22.04\home\localadmin\repos\@larcity\cami\bin\tunnel.ps1
```

#### Instructions on macOS

Follow these steps to setup `ngrok` for your local environment:

- Ensure you have updated your `.envrc` file with the `NGROK_AUTH_TOKEN`. You can get this from KeePass
- Run the following script to export the token to your local `ngrok.yml` config file:

  ```shell
  ngrok config add-authtoken ${NGROK_AUTH_TOKEN}
  ```

- Finally, generate your `config/ngrok.yml` file by running the following command:

  ```shell
  bin/thor lx-cli:tunnel:init
  ```

Now you can open a tunnel to your local environment by running:

```shell
thor lx-cli:tunnel:open_all
```

### Print key file

```shell
bin/thor help lx-cli:secrets:print_key
```

### Handling fixture files

A few helpful commands for handling fixture files.

#### Sanitizing an existing fixture file

```shell
# Show help menu for the sanitize command
bin/thor help lx-cli:fixtures:sanitize

# Sanitize the fixture file (outputs to the same directory as the fixture)
bin/thor lx-cli:fixtures:sanitize --file ./path/to/fixture.yml
```

#### Converting a JSON fixture file to a YAML fixture file

You can review [this guide](https://stackoverflow.com/a/67610900) for more tips
on using the `yq` command to transform (fixture) files.

```shell
# Convert the JSON fixture file to a YAML fixture file
yq -p json -o yaml ./path/to/fixture.json > ./path/to/fixture.yml
```
