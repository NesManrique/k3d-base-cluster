# Self Managed Argo CD with App of Apps Pattern using Helm

## Installation

```
$ cd argocd-install 
$ helm upgrade -i argocd ./argo-cd \
    --namespace=argocd \ 
    --create-namespace \ 
    -f values-override.yaml
```

## Directories
.
├── README.md
├── argocd-install    - Contains argocd helm chart and values for self mgmt.
│   └── argocd        - Argo CD upstream helm chart
├── argocd-apps       - Contains Argo Application Definitions.
└── argocd-projects   - Contains Argo Projects Definitions.
