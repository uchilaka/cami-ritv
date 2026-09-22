# CAMI: Running the stack with `docker compose`

- [How `COMPOSE_FILE` gets built](#how-compose_file-gets-built)
- [`compose.override.yml` is required and untracked](#composeoverrideyml-is-required-and-untracked)
- [Merge tags: `!reset` and `!override`](#merge-tags-reset-and-override)
- [Interpolation happens before merging](#interpolation-happens-before-merging)
- [Environment variables compose hard-requires](#environment-variables-compose-hard-requires)
- [Networks are external and provisioned separately](#networks-are-external-and-provisioned-separately)
- [Profiles](#profiles)
- [Smoke test](#smoke-test)
- [Troubleshooting](#troubleshooting)
  - [`required variable X is missing a value`](#required-variable-x-is-missing-a-value)
  - [`network larcity_apps declared as external, but could not be found`](#network-larcity_apps-declared-as-external-but-could-not-be-found)
  - [`docker compose` behaves differently in different terminals](#docker-compose-behaves-differently-in-different-terminals)
  - [WSL2 issues](#wsl2-issues)

Environment *file* selection — which `.env.*` files load and why — is a separate concern,
documented in [ENVIRONMENTS.md](./ENVIRONMENTS.md). This page covers what happens after
those files are loaded, when Compose reads them.

## How `COMPOSE_FILE` gets built

No `-f` flag appears in normal use. `.envrc` walks a fixed list, appends every file that
exists to `COMPOSE_FILE` (`:`-separated), and exports it; `docker compose` reads that
variable from the environment. The list, in merge order — **later files win**:

| Order | File | Tracked? |
|---|---|---|
| 1 | `compose.yml` | yes |
| 2 | `docker-compose.yml` | no (legacy name, absent) |
| 3 | `compose.${RUBY_ENV}.yml` | `compose.lab.yml` only |
| 4 | `compose.override.yml` | **no — you create it** |
| 5 | `docker-compose.override.yml` | no (legacy name, absent) |

You can see it happen in direnv's output on `cd`:

```text
🐳 Adding compose.yml to COMPOSE_FILE
⚠️ Compose file not found: .../docker-compose.yml. Skipping.
⚠️ Compose file not found: .../compose.development.yml. Skipping.
🐳 Adding compose.override.yml to COMPOSE_FILE
```

The "not found" lines are expected for the legacy `docker-compose*` names and for
`compose.development.yml`, which does not exist. Only line 4 matters.

> The Thor CLI resolves the same two files independently, in
> `lib/lar_city/cli/service_helpers.rb` (`compose_config_file` /
> `compose_override_config_file`), falling back to `compose.yml` and `compose.override.yml`
> under `Rails.root`. It reads them to answer questions like "what services exist"; it does
> not re-derive `COMPOSE_FILE`.

## `compose.override.yml` is required and untracked

`.gitignore:157` ignores `/*compose.override.yml`, so a fresh clone has no override layer
at all — and without it the stack does not run the way local development expects. Copy the
committed template:

```shell
cp compose.override.yml.example compose.override.yml
```

The template is the only tracked description of that layer. It is deliberately unencrypted,
so a clone with no `git-crypt` key can still read it. What it changes:

| Service | Override | Why |
|---|---|---|
| `web`, `worker` | `image:` points at `${CONTAINER_REGISTRY_HOST}/${CONTAINER_NAME_PREFIX}-*:latest` | run the published image instead of building from `Dockerfile.*` |
| `web`, `worker` | `APP_DATABASE_PASSWORD: !reset null` | the app-store accepts `trust` auth locally, so no password enters the container |
| `web` | `healthcheck: !override` | shorter interval/retries than the base file |
| `app-store` | `environment: !override` with `POSTGRES_HOST_AUTH_METHOD: trust` | password-free local Postgres |
| `app-store` | `healthcheck: !override` | `pg_isready` against the primary database |

Edit your copy freely — it is yours, and it is the intended place for machine-local compose
tweaks. Keep `compose.override.yml.example` in sync when a change should reach everyone.

## Merge tags: `!reset` and `!override`

Both require **Compose v2.24 or newer** (`docker compose version`). On an older CLI they
are parsed as unknown YAML tags and the file fails to load.

- `!reset null` — delete a key the base file set. Merging alone cannot remove a key; it can
  only add or replace one, and replacing with an empty string still passes an empty variable
  into the container.
- `!override` — replace a mapping or list wholesale rather than merging into it. Used on
  `healthcheck:` and on `app-store`'s `environment:` because a partial merge would leave
  whichever keys the override omits still in force, which is almost never what you want for
  a healthcheck.

## Interpolation happens before merging

This is the non-obvious one, and it is worth internalising before you debug an error
message that looks wrong.

Compose resolves `${VAR}` expressions in **every** file first, then merges the results. So
`!reset null` in the override does not excuse you from setting a variable that the base file
declares required:

```yaml
# compose.yml
APP_DATABASE_PASSWORD: ${APP_DATABASE_PASSWORD:?APP_DATABASE_PASSWORD must be set}

# compose.override.yml
APP_DATABASE_PASSWORD: !reset null
```

`APP_DATABASE_PASSWORD` must still hold a **non-empty** value or every compose command
aborts — even though no container will ever see it. Two related facts:

- `${VAR:?msg}` fails on an **empty** value, not just an unset one. `APP_DATABASE_USER=` in
  your `.env.development.local` is a failure, not a default.
- `${VAR}` with no `:?` and no `:-` only warns (`variable is not set. Defaulting to a blank
  string.`) and continues.

## Environment variables compose hard-requires

Every name below is written `${VAR:?...}` somewhere in `compose.yml` or
`compose.override.yml`. A missing **or empty** value aborts the command.

| Variable | Belongs in | Notes |
|---|---|---|
| `RUBY_ENV` | `.env.local` | not read by Compose, but `.envrc` refuses to load without it (ENVIRONMENTS.md R1) |
| `CONTAINER_REGISTRY_HOST` | `.env.local` | also `:?`-guarded by `.envrc` |
| `CONTAINER_NAME_PREFIX` | `.env.local` | also `:?`-guarded by `.envrc` |
| `APP_CONFIG_JWT_SECRET_KEY` | `.env.local` | `web`, `worker` |
| `RAILS_ENV` | `.env.<env>` (tracked) | never set it by hand — ENVIRONMENTS.md R3 |
| `APP_DATABASE_NAME_PRIMARY` | `.env.<env>.local` | `app-store`, `web`, `worker` |
| `APP_DATABASE_NAME_CRM` | `.env.<env>.local` | `app-store`, `web`, `worker`, `crm-*` |
| `APP_DATABASE_USER` | `.env.<env>.local` | `app-store`, `web`, `worker` |
| `APP_DATABASE_PASSWORD` | `.env.<env>.local` | non-empty, despite the `!reset` above |
| `PLATFORM_SUBDOMAIN` | `.env.<env>.local` | Traefik router hosts for `web` and `crm-app`; environment-shaped, so R2 keeps it out of `.env.local` |
| `APP_SECRET` | `.env.<env>` (git-crypt) | `crm-app`, `crm-worker` |
| `GITCRYPT_KEY_BASE64` | derived | `.envrc` base64-encodes `$GITCRYPT_KEY_FILE`; nothing to set by hand |

Everything else Compose mentions is soft. The blank-by-default Twenty CRM knobs
(`SMTP_USER`, `STORAGE_S3_*`, `DISABLE_DB_MIGRATIONS`, `DISABLE_CRON_JOBS_REGISTRATION`)
are declared empty in `.env.development.local.example` purely to keep the warnings out of
your terminal.

## Networks are external and provisioned separately

`compose.yml` declares both of its networks `external: true`, which means **Compose will
not create them** — it errors if they are absent. That is deliberate: `larcity_apps` is
shared with `platform-monorepo`, and `larcity-beta-net` belongs to that project's Traefik
spoke, so a `docker compose down` here must never take one out from under it.

`LarCity::CLI::ServiceNetworks#ensure_service_networks!`
(`lib/lar_city/cli/service_networks.rb`) creates any that are missing. Only the two Thor
entrypoints call it — `services:start`
(`lib/commands/lar_city/cli/services_cmd.rb:198`) and `init_app`
(`lib/commands/init_app.thor:36`). The `mise run` tasks and a raw `docker compose up` do
not, so a cold machine has to come up through Thor at least once:

```shell
bin/thor services:start
```

To create them by hand:

```shell
docker network create larcity_apps      --driver bridge --ipv6=false
docker network create larcity-beta-net  --driver bridge --ipv6=false
docker network create larcity-apps-net  --driver bridge --ipv6=false
```

> `--ipv6` is a boolean flag. `--ipv6 false` is parsed as a second positional argument and
> docker rejects the whole command with "requires 1 argument".

## Profiles

Every service is behind a profile, so a bare `docker compose up` starts nothing. Two
entrypoints select one, and they do **not** share a mechanism:

- **`mise run <task>`** — the tasks in `mise.toml` all pass `--profile $COMPOSE_PROFILE`.
  `mise.toml:15` declares `COMPOSE_PROFILE` `required = true`, so mise refuses to run
  without it; it is set in `.env.local` (see `.env.local.example`). Any profile name works.
- **`bin/thor services:start`** — ignores `COMPOSE_PROFILE` entirely. It takes a `--profile`
  option (`lib/commands/lar_city/cli/services_cmd.rb:11`) that defaults to
  `batteries-included` and is enum-restricted to `all`, `essential` and
  `batteries-included`, so `standalone` and `crm` are not reachable through it.

Only the Thor path provisions the external networks, so on a cold machine start there and
switch to `mise run` afterwards.

| Profile | Services |
|---|---|
| `essential` | `app-store`, `redis`, `crm-app`, `crm-worker` |
| `crm` | `app-store`, `redis`, `crm-app`, `crm-worker` — identical to `essential` today |
| `standalone` | `app-store`, `web`, `worker` — the Rails app without the CRM or Redis |
| `batteries-included` | `essential` + `web`, `worker`, `mailhog` |
| `all` | everything — `batteries-included` + `tunnel` |

Neither `essential` nor `crm` includes `web`, so the profile that actually runs this
application locally is `standalone` or `batteries-included`.

## Smoke test

`config` resolves the full merge — every `.env` file, every `${VAR}`, every merge tag —
without starting a container. It is the fastest way to prove the environment is sound:

```shell
yarn check:compose
```

Silence means success. To see the resolved stack instead of just validating it, drop the
`--quiet` that script passes:

```shell
docker compose config
```

## Troubleshooting

### `required variable X is missing a value`

`X` is `:?`-guarded — see [the table above](#environment-variables-compose-hard-requires)
for where it belongs. Check for an **empty** assignment before assuming it is absent:

```shell
direnv exec . sh -c 'echo "[$APP_DATABASE_USER]"'   # [] means empty, not unset
```

If `X` is `PLATFORM_SUBDOMAIN` you are almost certainly on a clone predating it being added
to `.env.local.example` — add it.

### `network larcity_apps declared as external, but could not be found`

The networks are not provisioned. Run `bin/thor services:start`, or create them by
hand — see [Networks](#networks-are-external-and-provisioned-separately).

### `docker compose` behaves differently in different terminals

`COMPOSE_FILE` comes from `.envrc`, so a shell where direnv has not loaded sees only
`compose.yml` and silently skips the override — different images, different healthchecks,
no `trust` auth. Confirm before debugging anything else:

```shell
echo "$COMPOSE_FILE"   # expect compose.yml:compose.override.yml
```

If it is empty, run `direnv allow`. In a new worktree this is a fresh trust decision, since
direnv trusts by path.

### WSL2 issues

#### My distribution can't connect to Docker Desktop

- Check that Docker Desktop is running.
- Check that Docker Desktop is enabled for your WSL2 distribution, at
  `Settings > Resources > WSL Integration`.

#### `Permission denied @ dir_initialize` for a mounted directory

- Check whether the mounted directories are set up with `root:root` ownership. See
  [this SO issue](https://stackoverflow.com/a/73673569/3726759) for details.
- Make sure your WSL distribution user is in the docker group:
  `sudo usermod -aG docker $USER`
- Check the directory's permissions with `ls -l`, and reassign ownership if it belongs to
  another user or group: `sudo chown -R $USER:$USER /path/to/directory`
