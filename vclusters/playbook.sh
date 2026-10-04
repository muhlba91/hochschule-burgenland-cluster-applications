#!/bin/bash

ROUTE_TYPE=${1:-httproute}
ZIP_PASSWORD=${2:-"password"}
INGRESS_PORT=${3:-8443}

# hostnames are stored differently: httproute -> .spec.hostnames, ingress -> .spec.rules[].host
case "${ROUTE_TYPE}" in
    httproute)
        HOST_PATH='{.spec.hostnames[*]}'
        PORT_SUFFIX=""
        ;;
    ingress)
        HOST_PATH='{.spec.rules[*].host}'
        PORT_SUFFIX=":${INGRESS_PORT}"
        ;;
esac

# fetch "<namespace> <hostname>" of all routes in cluster-* namespaces
routes=$(kubectl get "${ROUTE_TYPE}" -A -o jsonpath="{range .items[*]}{.metadata.namespace} ${HOST_PATH}{\"\\n\"}{end}" | grep '^cluster-' | sort -u)

# derive cluster names (from the namespace) and hostnames (from the route)
clusters=()
hostnames=()
while read -r namespace hostname _; do
    [ -z "${hostname}" ] && continue
    clusters+=("${namespace#cluster-}")
    hostnames+=("${hostname}")
done <<< "${routes}"

# generate configuration for each cluster
for i in "${!clusters[@]}"; do
    cluster=${clusters[$i]}
    hostname=${hostnames[$i]}
    echo "connecting to cluster-${cluster}..."
    vcluster connect "cluster-${cluster}" -n "cluster-${cluster}" --server="https://${hostname}${PORT_SUFFIX}" --service-account admin --cluster-role cluster-admin --insecure --print > "vclusters/configs/cluster-${cluster}.conf"
    KUBECONFIG="vclusters/configs/cluster-${cluster}.conf" kubectl get pod -A

    echo "zipping configuration for cluster-${cluster}..."
    zip -ejq "vclusters/configs/cluster-${cluster}.zip" "vclusters/configs/cluster-${cluster}.conf" -P "${ZIP_PASSWORD}"
done

# copy configuration to the cluster-access pod
CLUSTER_ACCESS_POD=$(kubectl -n vcluster-access get pod -l "app.kubernetes.io/name=cluster-access" -o jsonpath="{.items[0].metadata.name}")
for cluster in "${clusters[@]}"; do
    echo "copying configuration for cluster-${cluster}..."
    kubectl -n vcluster-access cp "vclusters/configs/cluster-${cluster}.zip" "${CLUSTER_ACCESS_POD}:/usr/share/nginx/html/files/"
done
