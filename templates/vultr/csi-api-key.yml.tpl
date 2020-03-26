apiVersion: v1
kind: Secret
metadata:
  name: vultr-csi
  namespace: kube-system
stringData:
  api-key: "${CLUSTER_API_KEY}"

