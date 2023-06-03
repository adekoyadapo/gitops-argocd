SUBNET_PREFIX=`docker network inspect kind | jq -r '.[0].IPAM.Config[0].Subnet' | awk -F. '{print $1"."$2}'`
NUM=255
cat << EOF > metallb.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kindip
  namespace: metallb
spec:
  addresses:
  - ${SUBNET_PREFIX}.${NUM}.100-${SUBNET_PREFIX}.${NUM}.254
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: kindip
  namespace: metallb
EOF

# kubectl apply -f metallb