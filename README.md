# Geniro Distribution

Deployment artifacts, packaging, and infrastructure tools for the **Geniro AI Agent Graph Platform**.

## Contents

| Directory | Description |
|---|---|
| [`helm/geniro/`](helm/geniro/) | Umbrella Helm chart — deploys API, Web, LiteLLM, Daytona, PostgreSQL, Redis, Keycloak, Qdrant |

> More directories will be added over time: Homebrew formula, docker-compose overrides, etc.

## Helm Chart

See [`helm/geniro/README.md`](helm/geniro/README.md) for full documentation.

### Quick Start

```bash
# Add dependency chart repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm repo update

# Download subchart dependencies
helm dependency update ./geniro-dist/helm/geniro

# Install with required secrets
helm install geniro ./geniro-dist/helm/geniro \
  --set secrets.credentialEncryptionKey=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))") \
  --set secrets.openrouterApiKey=sk-or-v1-... \
  --set secrets.litellmMasterKey=$(openssl rand -hex 32) \
  --set secrets.litellmSaltKey=$(openssl rand -hex 32) \
  --set keycloak.auth.adminPassword=$(openssl rand -hex 16) \
  --set keycloak.realm.seedUser.password=ChangeMeOnFirstLogin1! \
  --set postgresql.auth.postgresPassword=$(openssl rand -hex 16) \
  --set postgresql.auth.password=$(openssl rand -hex 16)
```

## License

Licensed under the [Apache License 2.0](../geniro/LICENSE) with additional conditions.
