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

Then create a project and it's config:
<details>

```yaml
apiVersion: kargo.akuity.io/v1alpha1
kind: Project
metadata:
  name: example--kargo

---

apiVersion: kargo.akuity.io/v1alpha1
kind: ProjectConfig
metadata:
  name: example--kargo
  # Namespace created based on the Project name
  namespace: example--kargo
spec:
  promotionPolicies:
  - stageSelector:
      name: cert-auto-ep3
    autoPromotionEnabled: true
  # - stageSelector:
  #     matchExpressions:
  #     - key: environment
  #       operator: In
  #       values:
  #       - devel
  #       - staging
  #   autoPromotionEnabled: true
```
</details>

Define your first warehouse
<details>

```yaml
apiVersion: kargo.akuity.io/v1alpha1
kind: Warehouse
metadata:
  name: argocd-warehouse
  namespace: example--kargo
spec:
  freightCreationPolicy: Automatic
  subscriptions:
  - chart:
      repoURL: https://argoproj.github.io/argo-helm
      name: argo-cd
      discoveryLimit: 20
```

</details>

Define your first stage

<details>

```yaml
apiVersion: kargo.akuity.io/v1alpha1
kind: Stage
metadata:
  name: devel
  namespace: example--kargo
  annotations:
    kargo.akuity.io/color: green
spec:
  requestedFreight:
  - origin:
      kind: Warehouse
      name: argocd-warehouse
    sources:
      direct: true
```

</details>

Kargo will automatically detect versions in the argo helm chart repo and create
the freights for you.

It will also automatically deploy them to the `devel` stage, because of the
`autoPromotionEnabled: true` setting in the ProjectConfig above.

However, it will also let you manually deploy freights to the stage (with
drag-and-drop).

However, these are just "virtual" deployments, it doesn't actually touch the
ArgoCD instance in your K8s cluster. To make it actually deploy the new versions
of the helm chart, you should configure argocd to auto apply the changes from
your git repository, and configure the ArgoCD `Application` to auto-sync. This
way, to update the ArgoCD instance to a new version, one just needs to update
the `targetRevision` field in the `Application` manifest in the git repo, and
ArgoCD will take care of the rest.

Now, that "one" could be you, manually, or Kargo, automatically.

# Make Kargo update on Git
To make Kargo update the git repository with the new version of the helm chart,

WIP