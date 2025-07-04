#!/bin/bash
set -e

# Configuration
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"  # Change to your preferred region
REPOSITORY="cami-ritv"
IMAGE_NAME="cami-ritv"
TAG="$(git rev-parse --short HEAD)"  # Using git commit hash as tag
FULL_IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

# Ensure user is authenticated with gcloud
if ! gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null; then
  echo "Please authenticate with gcloud first:"
  echo "gcloud auth login"
  exit 1
fi

# Ensure docker is authenticated to the artifact registry
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

# Build the Docker image
echo "Building Docker image..."
docker build -t "${FULL_IMAGE_NAME}" .

# Push the Docker image
echo "Pushing Docker image to Google Artifact Registry..."
docker push "${FULL_IMAGE_NAME}"

echo "Image successfully pushed to: ${FULL_IMAGE_NAME}"

# Create a latest tag
LATEST_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:latest"
docker tag "${FULL_IMAGE_NAME}" "${LATEST_TAG}"
docker push "${LATEST_TAG}"

echo "Latest tag updated to: ${LATEST_TAG}"
