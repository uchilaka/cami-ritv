#!/usr/bin/env bash
set -euo pipefail

# Exit immediately if a command fails
function error_exit {
    echo "❌ Error: $1" >&2
    exit 1
}

# Load environment variables from .env file if it exists
if [[ -f "${BASH_SOURCE%/*}/../.env" ]]; then
    # shellcheck source=/dev/null
    source "${BASH_SOURCE%/*}/../.env"
fi

# Configuration with environment variable fallbacks
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID must be set in .env or environment}"
: "${GCP_REGION:=us-central1}"  # Default to us-central1 if not set
: "${GCP_ARTIFACT_REPOSITORY:=cami-ritv}"
: "${DOCKER_IMAGE_NAME:=cami-ritv}"

# Get versions
GIT_COMMIT=$(git rev-parse --short HEAD) || error_exit "Failed to get git commit hash"
RUBY_VERSION="3.4.3"  # From .tool-versions
NODE_VERSION="24.3.0"  # From .tool-versions

# Sanitize versions for Docker tags
SANITIZED_RUBY_VERSION=$(echo "${RUBY_VERSION}" | tr '.' '-')
SANITIZED_NODE_VERSION=$(echo "${NODE_VERSION}" | tr '.' '-')

# Image tags
IMAGE_TAG="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${GCP_ARTIFACT_REPOSITORY}/${DOCKER_IMAGE_NAME}:ruby-${SANITIZED_RUBY_VERSION}-node-${SANITIZED_NODE_VERSION}-${GIT_COMMIT}"
LATEST_TAG="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${GCP_ARTIFACT_REPOSITORY}/${DOCKER_IMAGE_NAME}:latest"
STABLE_TAG="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${GCP_ARTIFACT_REPOSITORY}/${DOCKER_IMAGE_NAME}:ruby-${SANITIZED_RUBY_VERSION}-node-${SANITIZED_NODE_VERSION}"

# Check for required commands
for cmd in docker gcloud git; do
  if ! command -v "${cmd}" &> /dev/null; then
    error_exit "${cmd} is required but not installed"
  fi
done

# Ensure user is authenticated with gcloud
if ! gcloud auth list --filter=status:ACTIVE --format='value(account)' &>/dev/null; then
    error_exit "Please authenticate with gcloud first:\n  gcloud auth login"
fi

# Ensure docker is authenticated to the artifact registry
echo "🔐 Authenticating Docker with Google Artifact Registry..."
gcloud auth configure-docker "${GCP_REGION}-docker.pkg.dev" --quiet || \
    error_exit "Failed to authenticate Docker with Google Artifact Registry"

# Build the Docker image
echo "🏗️  Building Docker image (${GIT_COMMIT})..."
docker build \
    --tag "${IMAGE_TAG}" \
    --build-arg RAILS_ENV=production \
    --build-arg NODE_ENV=production \
    . || error_exit "Docker build failed"

# Push the Docker image
echo "🚀 Pushing Docker image to Google Artifact Registry..."
docker push "${IMAGE_TAG}" || error_exit "Failed to push image"

# Create and push versioned tags
echo "🏷️  Updating tags..."

# Latest tag (always points to most recent build)
docker tag "${IMAGE_TAG}" "${LATEST_TAG}" || error_exit "Failed to tag image as latest"
docker push "${LATEST_TAG}" || error_exit "Failed to push latest tag"

# Versioned tag (points to this specific Ruby/Node version)
docker tag "${IMAGE_TAG}" "${STABLE_TAG}" || error_exit "Failed to tag image as versioned"
docker push "${STABLE_TAG}" || error_exit "Failed to push versioned tag"

echo -e "\n✅ Success!"
echo "📦 Image: ${IMAGE_TAG}"
echo "🏷️  Stable: ${STABLE_TAG}"
echo "🔖 Latest: ${LATEST_TAG}"
