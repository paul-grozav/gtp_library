# Terminology
**Kargo** allows you to define deploy strategies, based on new versions of
container images or helm chart versions detected in a registry/repository.

A **Warehouse** is subscribed to / watches one or more registries or
repositories for new versions of container images or helm charts.

A **Stage** could be an environment like "development", "staging" or
"production", or just a server. It's basically a place where you want to deploy
the new versions of your applications to.

A **Freight** is a specific version or set of apps that need to be deployed to a
specific stage. A Freight is created automatically when new versions of images
or charts are detected in the warehouse.

# Definition objects
Install Kargo:

<details>

```yaml
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kargo
  namespace: argocd
spec:
  project: default
  destination:
    namespace: kargo
    server: https://kubernetes.default.svc
  source:
    repoURL: ghcr.io/akuity/kargo-charts
    chart: kargo
    targetRevision: "*"
    helm:
      parameters:
      - name: api.adminAccount.passwordHash
        # pass=$(openssl rand -base64 48 | tr -d "=+/" | head -c 32)
        # echo "Password: ${pass}"
        # echo "Password Hash: $(htpasswd -bnBC 10 "" ${pass} | tr -d ':\n')"
        # echo "Signing Key: $(openssl rand -base64 48 |tr -d "=+/" |head -c32)"
        # Note: A bcrypt-hashed password will contain `$` characters that
        # MUST each be escaped as `$$`
        value: XY$$Z
      - name: api.adminAccount.tokenSigningKey
        value: ABC
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
# ============================================================================ #
```

</details>

Then create a project:
<details>

```yaml
apiVersion: kargo.akuity.io/v1alpha1
kind: Project
metadata:
  name: example--kargo
```
</details>
