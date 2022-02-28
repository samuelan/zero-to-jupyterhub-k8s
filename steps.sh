
#!/bin/bash

helm_release_name='jup-release'
k8s_namespace='ns-jupyter'

helm upgrade --cleanup-on-fail \
  --install  ${helm_release_name} jupyterhub \
  --namespace  ${k8s_namespace} \
  --create-namespace \
  --version=1.2.0 \
  --values /Users/sam/Downloads/jupyterhub/values.yaml