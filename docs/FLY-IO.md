# CAMI: On-boarding with Fly.io

## Setup prerequisites

> The preferred region for this project is `iad` (Ashburn, VA) due to its proximity to the majority of our users. If you choose to deploy to a different region, ensure that you select a region that is geographically close to your user base.

### Setting up Managed PostgreSQL

LarCity uses the [Fly.io Managed PostgreSQL](https://fly.io/docs/postgres/) service to host the app database in production. To set up a new cluster, run:

```shell
fly mpg create <cluster-name> --org larcity-llc --region iad
```

### Setting up volumes

```shell
flyctl volumes create core_storage --count 2 --size 10 --app cami-production --region iad --vm-cpu-kind shared --vm-cpus 1
```

### Setting up secrets

```shell
fly secrets set --stage --detach --app=cami-production --access-token="<APP-DEPLOY-API-TOKEN>" NAME="<VALUE>"
```

## Launch the app

### 1. Install flyctl

```shell
# Install all system dependencies
brew bundle --file="Brewfile.$RAILS_ENV"

# Install flyctl specifically
brew install flyctl
```

### 2. Create and deploy to a new fly.io app

```shell
fly launch --name <app-name> --org larcity-llc --region <region> --image <image-name> --now
```

### 3. Set up secrets

```shell
fly secrets set <SECRET_KEY>=<SECRET_VALUE> --app <app-name>
```

### 4. View app logs

```shell
fly logs --app <app-name>
```

### 5. Connect to a fly.io app instance

```shell
fly ssh console --app <app-name>
```

### 6. Manage postgreSQL database

```shell
# Confirm that your MPG cluster is ready
fly mpg status

# Attach the cluster to your app 
fly mpg attach <cluster-name> --app <app-name>
```
