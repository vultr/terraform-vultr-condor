apiVersion: v1
kind: Secret
metadata:
  name: vultr-ccm
  namespace: kube-system
stringData:
  api-key: "${CLUSTER_API_KEY}"
  region: "${CLUSTER_REGION}"

