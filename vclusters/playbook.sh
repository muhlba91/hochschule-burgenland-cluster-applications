#!/bin/bash

ZIP_PASSWORD=${ZIP_PASSWORD:-"password"}

# fetch clusters
clusters=($(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^cluster-' | sed 's/^cluster-//'))

# generate configuration for each cluster
for cluster in "${clusters[@]}"; do
    echo "connecting to cluster-${cluster}..."
    vcluster connect cluster-${cluster} -n cluster-${cluster} --server=https://${cluster}.cluster.classroom.hochschule-burgenland.muehlbachler.xyz --service-account admin --cluster-role cluster-admin --insecure --print > vclusters/configs/cluster-${cluster}.conf
    KUBECONFIG="vclusters/configs/cluster-${cluster}.conf" kubectl get pod -A

    echo "zipping configuration for cluster-${cluster}..."
    zip -ejq vclusters/configs/cluster-${cluster}.zip vclusters/configs/cluster-${cluster}.conf -P ${ZIP_PASSWORD}
done

# copy configuration to the cluster-access pod
CLUSTER_ACCESS_POD=$(kubectl -n vcluster-access get pod -l "app.kubernetes.io/name=cluster-access" -o jsonpath="{.items[0].metadata.name}")
for cluster in ${CLUSTER_IDS}; do
    echo "copying configuration for cluster-${cluster}..."
    kubectl -n vcluster-access cp vclusters/configs/cluster-${cluster}.zip $CLUSTER_ACCESS_POD:/usr/share/nginx/html/files/
done
