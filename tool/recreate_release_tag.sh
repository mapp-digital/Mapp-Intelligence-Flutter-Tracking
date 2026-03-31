#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 5.0.11"
  exit 1
fi

VERSION="$1"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: $VERSION"
  echo "Expected format: <major>.<minor>.<patch>"
  exit 1
fi

TAG="v$VERSION"

echo "Recreating tag $TAG"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Deleting local tag $TAG"
  git tag -d "$TAG"
else
  echo "Local tag $TAG does not exist"
fi

echo "Deleting remote tag $TAG if it exists"
git push origin --delete "$TAG" 2>/dev/null || true

echo "Creating local tag $TAG"
git tag "$TAG"

echo "Pushing tag $TAG"
git push origin "$TAG"

echo "Done"
