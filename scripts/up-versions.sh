#!/bin/bash
set -euo pipefail

pnpm semantic-release -t "@geniro-dist/chart@\${version}" --no-ci
