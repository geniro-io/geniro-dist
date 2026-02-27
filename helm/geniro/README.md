# Geniro Helm Chart

Umbrella Helm chart for the **Geniro AI Agent Graph Platform**. Deploys the API, Web UI, LiteLLM proxy, and optional Daytona sandbox runtime, along with PostgreSQL, Redis, Keycloak, and Qdrant as bundled dependencies.

## Prerequisites

- [Helm 3.12+](https://helm.sh/docs/intro/install/)
- Kubernetes 1.27+
- An ingress controller (e.g., ingress-nginx) if you enable ingress resources

## Quick Start

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
  --set secrets.openrouterApiKey=sk-or-v1-...
```

After install, follow the NOTES output for port-forward commands.

## Key Values

| Parameter | Description | Default |
|---|---|---|
| `secrets.credentialEncryptionKey` | **Required.** 64-char hex key for AES-256-GCM encryption | `""` |
| `secrets.openrouterApiKey` | OpenRouter API key for LLM access | `""` |
| `secrets.litellmMasterKey` | LiteLLM admin key | `"master"` |
| `api.image.tag` | API image tag | `latest` |
| `api.replicas` | API replica count | `1` |
| `api.ingress.enabled` | Enable API ingress | `false` |
| `api.mountDockerSocket` | Mount host Docker socket for tool execution | `false` |
| `web.image.tag` | Web UI image tag | `latest` |
| `web.ingress.enabled` | Enable Web UI ingress | `false` |
| `litellm.enabled` | Deploy LiteLLM proxy | `true` |
| `daytona.enabled` | Deploy Daytona sandbox runtime | `false` |
| `postgresql.enabled` | Deploy bundled PostgreSQL | `true` |
| `redis.enabled` | Deploy bundled Redis | `true` |
| `keycloak.enabled` | Deploy bundled Keycloak | `true` |
| `qdrant.enabled` | Deploy bundled Qdrant | `true` |

See [`values.yaml`](values.yaml) for the full reference with comments.

## Example Values

A ready-to-use example configuration with LLM models pre-configured via OpenRouter:

```bash
# Copy and edit the example (replace placeholder keys)
cp ./geniro-dist/helm/geniro/examples/quickstart-values.yaml my-values.yaml
vim my-values.yaml

# Install with your values
helm install geniro ./geniro-dist/helm/geniro -f my-values.yaml
```

See [`examples/quickstart-values.yaml`](examples/quickstart-values.yaml) for a fully commented configuration with Anthropic, OpenAI, Google, and DeepSeek models routed through OpenRouter.

## Using External Services

Disable any bundled dependency and point to your own:

```bash
# External PostgreSQL
helm install geniro ./geniro-dist/helm/geniro \
  --set postgresql.enabled=false \
  --set externalPostgresql.host=my-pg.example.com \
  --set externalPostgresql.password=mypassword \
  --set secrets.credentialEncryptionKey=<64-char-hex>

# External Redis
helm install geniro ./geniro-dist/helm/geniro \
  --set redis.enabled=false \
  --set externalRedis.host=my-redis.example.com \
  --set secrets.credentialEncryptionKey=<64-char-hex>

# External Keycloak
helm install geniro ./geniro-dist/helm/geniro \
  --set keycloak.enabled=false \
  --set externalKeycloak.url=https://auth.example.com \
  --set externalKeycloak.realm=geniro \
  --set secrets.credentialEncryptionKey=<64-char-hex>
```

## Daytona Sandbox Runtime

To use Daytona instead of (or alongside) the host Docker socket for tool execution:

```bash
helm install geniro ./geniro-dist/helm/geniro \
  --set daytona.enabled=true \
  --set api.mountDockerSocket=false \
  --set secrets.credentialEncryptionKey=<64-char-hex>
```

The Daytona runner pod requires `privileged: true` security context for container-in-container execution.

## Web Frontend Note

The Web UI image has `API_URL` compiled at build time in `geniro-web/src/config/production.ts`. For custom domains, edit that file and rebuild the image before deploying.

## Troubleshooting

**Pods stuck in CrashLoopBackOff:**
```bash
kubectl logs -n <namespace> -l app.kubernetes.io/component=api --tail=50
```

**Database not ready:**
The API deployment does not include init-containers for database readiness. If the API starts before PostgreSQL is ready, it will crash and restart. Kubernetes will retry automatically. If it persists, check the PostgreSQL pod logs.

**Keycloak realm not imported:**
The Keycloak deployment uses `start-dev --import-realm` and mounts the realm JSON at `/opt/keycloak/data/import`. Check that the `geniro-keycloak-realm` configmap exists and Keycloak logs show "Realm 'geniro' imported".

**Ingress not working:**
Verify an ingress controller is installed: `kubectl get ingressclass`. The chart does not install an ingress controller itself.

## Linting and Testing

```bash
# Lint the chart
helm lint ./geniro-dist/helm/geniro -f ./geniro-dist/helm/geniro/ci/test-values.yaml

# Render templates locally
helm template geniro ./geniro-dist/helm/geniro -f ./geniro-dist/helm/geniro/ci/test-values.yaml
```
