<div align="center">

<img src="assets/logo.png" alt="Geniro" width="400" />

</div>

# Geniro Distribution

Deployment artifacts, packaging, and infrastructure tools for the **Geniro AI Agent Graph Platform**.

## Contents

| Directory | Description |
|---|---|
| [`helm/geniro/`](helm/geniro/) | Umbrella Helm chart — deploys API, Web, LiteLLM, Daytona, PostgreSQL, Redis, Keycloak, Qdrant |

> More directories will be added over time: Homebrew formula, docker-compose overrides, etc.

## Helm Chart

See [`helm/geniro/README.md`](helm/geniro/README.md) for full documentation.

### Install from OCI Registry (Recommended)

```bash
helm install geniro oci://docker.io/razumru/geniro \
  --version <version> \
  --set secrets.credentialEncryptionKey=$(openssl rand -hex 32) \
  --set secrets.openrouterApiKey=sk-or-v1-... \
  --set secrets.litellmMasterKey=$(openssl rand -hex 32) \
  --set secrets.litellmSaltKey=$(openssl rand -hex 32) \
  --set keycloak.auth.adminPassword=$(openssl rand -hex 16) \
  --set keycloak.realm.seedUser.password=ChangeMeOnFirstLogin1! \
  --set postgresql.auth.postgresPassword=$(openssl rand -hex 16) \
  --set postgresql.auth.password=$(openssl rand -hex 16) \
  -n geniro --create-namespace

# Or with a values file
helm install geniro oci://docker.io/razumru/geniro \
  --version <version> \
  -f my-values.yaml \
  -n geniro --create-namespace
```

### Install from Source

```bash
# Add dependency chart repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm repo update

# Download subchart dependencies
helm dependency update ./helm/geniro

# Install with required secrets
helm install geniro ./helm/geniro \
  --set secrets.credentialEncryptionKey=$(openssl rand -hex 32) \
  --set secrets.openrouterApiKey=sk-or-v1-... \
  --set secrets.litellmMasterKey=$(openssl rand -hex 32) \
  --set secrets.litellmSaltKey=$(openssl rand -hex 32) \
  --set keycloak.auth.adminPassword=$(openssl rand -hex 16) \
  --set keycloak.realm.seedUser.password=ChangeMeOnFirstLogin1! \
  --set postgresql.auth.postgresPassword=$(openssl rand -hex 16) \
  --set postgresql.auth.password=$(openssl rand -hex 16) \
  -n geniro --create-namespace
```

## License

Licensed under the [Apache License 2.0](LICENSE) with additional conditions. A commercial license is required for operating a multi-tenant SaaS. See [LICENSE](LICENSE) for details.
