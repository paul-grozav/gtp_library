Install [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) using:

```sh
# Install
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml &&
helm repo add argo https://argoproj.github.io/argo-helm &&
helm install argocd \
  argo/argo-cd \
  --create-namespace \
  --namespace argocd \
  --set configs.params."application\.namespaces"=* \
  &&

# Get administrative password:
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo &&

kubectl -n argocd port-forward service/argocd-server 443:1443 &&
# Open https://localhost:1443/ and login with user admin and the password above.
```

Apply the [bootstrap](./bootstrap_app.yaml) app:
```sh
kubectl apply -f ./bootstrap_app.yaml
```
That will install the other ArgoCD apps, K8s manifests and Helm charts.

```sh
# Show when ArgoCD last time changed an object:
kubectl -n kube-system get configmap coredns -o yaml --show-managed-fields |
  yq -y \
  '.metadata.managedFields[] | select(.manager=="argocd-controller") | .time' |
  yq -r '.'
```
