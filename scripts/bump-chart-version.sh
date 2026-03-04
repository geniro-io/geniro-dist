#!/bin/bash
set -euo pipefail

VERSION="$1"
CHART_FILE="helm/geniro/Chart.yaml"

echo "Bumping Chart.yaml version to ${VERSION}..."

sed -i.bak "s/^version: .*/version: ${VERSION}/" "${CHART_FILE}"
rm -f "${CHART_FILE}.bak"

# Verify the bump succeeded
ACTUAL=$(grep '^version:' "${CHART_FILE}" | awk '{print $2}')
if [ "${ACTUAL}" != "${VERSION}" ]; then
  echo "ERROR: Chart.yaml version is '${ACTUAL}', expected '${VERSION}'"
  exit 1
fi

echo "Chart.yaml version updated to ${VERSION}"
