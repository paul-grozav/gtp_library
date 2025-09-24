# Terminology
Chart is the recipe(folder containing the Chart.yaml), templates that get
processed by jinja.

A Release is an instance of the chart, installed on a certain cluster, in a
certain namespace, with a given release name.

# Commands
```sh
# Getting the full manifest of a release
helm get manifest -n my-namespace my-release-name
# Or with kubectl
kubectl get secret -n my-namespace -l owner=helm,name=my-release-name -o yaml | yq -r .items[0].data.release | base64 -d | base64 -d | gunzip -c | jq '.manifest' -r

# Show helm chart versions available in the repo 
helm search repo grafana/grafana --versions
```

# Helmfile

```sh
# Show differences
helmfile diff --skip-deps
# Apply local defition
helmfile apply --skip-deps
# Destroy one component
helmfile destroy --selector name=my-component
```
