# Create ns
for context in ${CLUSTER1} ${CLUSTER2}; do
    kubectl --context ${context} create namespace gloo-test || true
    kubectl --context ${context} label namespace gloo-test istio.io/dataplane-mode=ambient
    kubectl --context ${context} apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/sleep/sleep.yaml -n gloo-test
done

# Create test apps
kubectl apply -f https://raw.githubusercontent.com/rvennam/ambient-mc-test/refs/heads/main/helloworld-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f https://raw.githubusercontent.com/rvennam/ambient-mc-test/refs/heads/main/helloworld-cluster2.yaml --context ${CLUSTER2}

sleep 5;

# Test cross cluster communication
echo "-------------------------------"
echo "> Calling cluster2 from cluster1"
kubectl exec --context ${CLUSTER1} -n gloo-test deploy/sleep -- curl -s helloworld-cluster2.gloo-test.mesh.internal:80
echo "-------------------------------"
echo "> Calling cluster1 from cluster2"
kubectl exec --context ${CLUSTER2} -n gloo-test deploy/sleep -- curl -s helloworld-cluster1.gloo-test.mesh.internal:80