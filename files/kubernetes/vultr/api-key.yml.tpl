apiVersion: v1
kind: Secret
metadata:
  name: vultr-ccm
  namespace: kube-system
stringData:
  # Replace the api-key and region with proper values
  api-key: "${CCM_API_KEY}"
  region: "${CLUSTER_REGION}"

