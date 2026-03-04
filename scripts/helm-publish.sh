#!/bin/bash
set -euo pipefail

VERSION="$1"
CHART_DIR="helm/geniro"
OCI_REGISTRY="oci://docker.io/razumru"
GHCR_REGISTRY="oci://ghcr.io/geniro-io"

echo "Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm repo add zitadel https://charts.zitadel.com

echo "Building chart dependencies..."
helm dependency build "${CHART_DIR}"

echo "Packaging chart v${VERSION}..."
helm package "${CHART_DIR}"

PACKAGE_FILE="geniro-${VERSION}.tgz"
if [ ! -f "${PACKAGE_FILE}" ]; then
  echo "ERROR: Expected package file '${PACKAGE_FILE}' not found"
  exit 1
fi

echo "Pushing ${PACKAGE_FILE} to ${OCI_REGISTRY}..."
helm push "${PACKAGE_FILE}" "${OCI_REGISTRY}"

echo "Pushing ${PACKAGE_FILE} to ${GHCR_REGISTRY}..."
helm push "${PACKAGE_FILE}" "${GHCR_REGISTRY}"

rm -f "${PACKAGE_FILE}"
echo "Published geniro chart v${VERSION} to ${OCI_REGISTRY} and ${GHCR_REGISTRY}"
